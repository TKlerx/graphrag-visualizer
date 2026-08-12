# Implementation Plan: PE IC GraphRAG Showcase

**Branch**: `001-pe-ic-graphrag` | **Date**: 2026-06-28 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/001-pe-ic-graphrag/spec.md`

## Summary

Update the React visualizer to support DRIFT retrieval and robust GraphRAG v2 artifacts, add Spec Kit traceability, and add public demo-corpus and IC memo-generation artifacts for a Forterro-style private equity showcase.

## Technical Context

**Language/Version**: TypeScript 4.9, React 18, PowerShell 7-compatible scripts

**Primary Dependencies**: Material UI, axios, hyparquet, react-force-graph, Spec Kit

**Storage**: Browser-loaded parquet files, ignored local demo corpus folders, Markdown/JSON documentation, Azure Storage for deployed corpus/artifacts

**Testing**: `specify check`, `pnpm build`, manual smoke checks with GraphRAG artifacts and `graphrag-api`

**Target Platform**: Browser app served by Create React App locally and Azure-hosted showcase resources for deployment

**Project Type**: Single frontend web application with local documentation and demo scripts

**Performance Goals**: Large GraphRAG entity sets remain navigable through upstream max-entity limiting

**Constraints**: No downloaded third-party corpus documents committed; no backend implementation added in this repo; OpenTofu provisions Azure resources but does not push container images

**Scale/Scope**: Demo corpus and workflow for one Forterro-style PE IC showcase

## Constitution Check

The generated constitution is still a placeholder. No project-specific gates are defined, so the plan proceeds with standard repo quality gates: build passes, Spec Kit check passes, downloaded documents remain ignored, and scope stays within the visualizer plus demo artifacts.

## Project Structure

### Documentation (this feature)

```text
specs/001-pe-ic-graphrag/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── tasks.md
└── checklists/
```

### Source Code and Demo Artifacts

```text
src/app/
├── api/
├── components/
├── hooks/
└── utils/

demo/
├── corpus/
├── ic-memo/
└── scripts/

infra/
└── opentofu/

docs/
└── azure-ai-foundry-graphrag.md
```

**Structure Decision**: Keep app changes inside the existing React source tree. Put showcase documents, question catalogue, and scripts under `demo/` so they are clearly separated from application runtime code.

## Complexity Tracking

No constitution violations or additional architectural complexity are required.
