from __future__ import annotations

import math
import os
from contextlib import asynccontextmanager
from dataclasses import dataclass
from pathlib import Path
from typing import Any

import graphrag.api as graphrag_api
import pandas as pd
import uvicorn
from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from graphrag.config.load_config import load_config


PROJECT_DIRECTORY = Path(os.environ.get("GRAPHRAG_PROJECT_DIR", "demo/graphrag/workspace")).resolve()
COMMUNITY_LEVEL = int(os.environ.get("GRAPHRAG_COMMUNITY_LEVEL", "2"))
RESPONSE_TYPE = os.environ.get("GRAPHRAG_RESPONSE_TYPE", "Single Paragraph")
HOST = os.environ.get("GRAPHRAG_API_HOST", "0.0.0.0")
PORT = int(os.environ.get("GRAPHRAG_API_PORT", "8000"))


GRAPH_PROJECTS = {
    "current": PROJECT_DIRECTORY,
    "default": PROJECT_DIRECTORY,
    "proalpha-target-v2": Path("demo/graphrag/workspace").resolve(),
    "forterro-only-v1": Path("demo/graphrag/workspace-forterro-v1").resolve(),
}


@dataclass
class GraphProject:
    graph_id: str
    project_path: Path
    config: Any
    entities: pd.DataFrame
    communities: pd.DataFrame
    community_reports: pd.DataFrame
    text_units: pd.DataFrame
    relationships: pd.DataFrame
    covariates: pd.DataFrame | None


def parquet_path(output_path: Path, name: str) -> Path:
    candidates = [
        output_path / f"{name}.parquet",
        output_path / f"create_final_{name}.parquet",
    ]
    for candidate in candidates:
        if candidate.exists():
            return candidate
    raise FileNotFoundError(f"Missing GraphRAG artifact for {name}: checked {candidates}")


def read_artifact(output_path: Path, name: str, required: bool = True) -> pd.DataFrame | None:
    try:
        return pd.read_parquet(parquet_path(output_path, name))
    except FileNotFoundError:
        if required:
            raise
        return None


def to_json_safe(value: Any) -> Any:
    if isinstance(value, pd.DataFrame):
        return to_json_safe(value.to_dict(orient="records"))
    if isinstance(value, list):
        return [to_json_safe(item) for item in value]
    if isinstance(value, dict):
        return {key: to_json_safe(item) for key, item in value.items()}
    if isinstance(value, pd.Timestamp):
        return value.isoformat()
    if pd.isna(value) if not isinstance(value, (list, dict, pd.DataFrame)) else False:
        return None
    if isinstance(value, float) and math.isnan(value):
        return None
    return value


def response_payload(response: Any, context: Any) -> JSONResponse:
    return JSONResponse(
        content={
            "response": response if isinstance(response, str) else str(response),
            "context_data": to_json_safe(context),
        }
    )


def available_graphs() -> dict[str, str]:
    return {
        graph_id: str(project_path)
        for graph_id, project_path in GRAPH_PROJECTS.items()
        if (project_path / "output").exists()
    }


def load_graph_project(graph_id: str, project_path: Path) -> GraphProject:
    output_path = project_path / "output"
    if not output_path.exists():
        raise FileNotFoundError(f"GraphRAG output folder not found: {output_path}")

    return GraphProject(
        graph_id=graph_id,
        project_path=project_path,
        config=load_config(project_path),
        entities=read_artifact(output_path, "entities"),
        communities=read_artifact(output_path, "communities"),
        community_reports=read_artifact(output_path, "community_reports"),
        text_units=read_artifact(output_path, "text_units"),
        relationships=read_artifact(output_path, "relationships"),
        covariates=read_artifact(output_path, "covariates", required=False),
    )


def get_graph_project(app: FastAPI, graph_id: str | None) -> GraphProject:
    selected_graph_id = graph_id or "default"
    if selected_graph_id not in GRAPH_PROJECTS:
        known = ", ".join(sorted(available_graphs()))
        raise HTTPException(
            status_code=400,
            detail=f"Unknown graph '{selected_graph_id}'. Known graphs: {known}",
        )

    if selected_graph_id not in app.state.graph_projects:
        app.state.graph_projects[selected_graph_id] = load_graph_project(
            selected_graph_id,
            GRAPH_PROJECTS[selected_graph_id],
        )

    return app.state.graph_projects[selected_graph_id]


@asynccontextmanager
async def lifespan(app: FastAPI):
    app.state.graph_projects = {}
    get_graph_project(app, "default")
    yield


app = FastAPI(title="GraphRAG Visualizer Local API", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",
        "http://127.0.0.1:3000",
        "https://noworneverev.github.io",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/status")
async def status():
    return {
        "status": "Server is up and running",
        "project_directory": str(PROJECT_DIRECTORY),
        "community_level": COMMUNITY_LEVEL,
        "available_graphs": available_graphs(),
    }


@app.get("/search/global")
async def global_search(
    query: str = Query(..., description="Global Search"),
    graph: str | None = Query(None, description="Graph id"),
):
    try:
        project = get_graph_project(app, graph)
        response, context = await graphrag_api.global_search(
            config=project.config,
            entities=project.entities,
            communities=project.communities,
            community_reports=project.community_reports,
            community_level=COMMUNITY_LEVEL,
            dynamic_community_selection=False,
            response_type=RESPONSE_TYPE,
            query=query,
        )
        return response_payload(response, context)
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@app.get("/search/local")
async def local_search(
    query: str = Query(..., description="Local Search"),
    graph: str | None = Query(None, description="Graph id"),
):
    try:
        project = get_graph_project(app, graph)
        response, context = await graphrag_api.local_search(
            config=project.config,
            entities=project.entities,
            communities=project.communities,
            community_reports=project.community_reports,
            text_units=project.text_units,
            relationships=project.relationships,
            covariates=project.covariates,
            community_level=COMMUNITY_LEVEL,
            response_type=RESPONSE_TYPE,
            query=query,
        )
        return response_payload(response, context)
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@app.get("/search/drift")
async def drift_search(
    query: str = Query(..., description="DRIFT Search"),
    graph: str | None = Query(None, description="Graph id"),
):
    try:
        project = get_graph_project(app, graph)
        response, context = await graphrag_api.drift_search(
            config=project.config,
            entities=project.entities,
            communities=project.communities,
            community_reports=project.community_reports,
            text_units=project.text_units,
            relationships=project.relationships,
            community_level=COMMUNITY_LEVEL,
            response_type=RESPONSE_TYPE,
            query=query,
        )
        return response_payload(response, context)
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@app.get("/search/basic")
async def basic_search(
    query: str = Query(..., description="Basic Search"),
    graph: str | None = Query(None, description="Graph id"),
):
    try:
        project = get_graph_project(app, graph)
        response, context = await graphrag_api.basic_search(
            config=project.config,
            text_units=project.text_units,
            response_type=RESPONSE_TYPE,
            query=query,
        )
        return response_payload(response, context)
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


if __name__ == "__main__":
    uvicorn.run(app, host=HOST, port=PORT)
