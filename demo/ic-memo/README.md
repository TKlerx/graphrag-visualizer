# IC Memo Generation Workflow

This folder contains a reusable question catalogue and a sample Markdown IC memo. The goal is to turn GraphRAG retrieval into an investment committee preparation workflow.

- `question-catalogue.json` is the machine-readable prompt catalogue.
- `section-prompt-plan.md` is the human-readable section-by-section prompt plan.
- `sample-forterro-ic-memo.md` is a static target-format example.
- `generated/` contains local generated outputs and query logs.

## Workflow

1. Build the public corpus with `demo/scripts/prepare-forterro-corpus.ps1`.
2. Run Microsoft GraphRAG indexing on the prepared text corpus.
3. Start `graphrag-api` for the same GraphRAG project.
4. For each section in `question-catalogue.json`, run:
   - Global Search for broad themes.
   - Local Search for source-backed facts.
   - Drift Search for second-pass diligence-gap discovery and thesis refinement.
5. Copy evidence into `sample-forterro-ic-memo.md` or a generated memo under `generated/`.
6. Keep unsupported items under assumptions or open diligence gaps.

For the first public-proxy Forterro memo, the full draft was generated with a single Global Search prompt, then DRIFT was tested separately for diligence-gap discovery after tuning. See `generated/forterro-public-proxy-query-log.md` for the exact commands.

## Run the Question Catalogue

With `graphrag-api` running:

```powershell
$env:GRAPHRAG_API_URL = "http://localhost:8000"
rtk pwsh -NoProfile -ExecutionPolicy Bypass -File demo/scripts/run-ic-question-catalogue.ps1
```

To start the local GraphRAG v3-compatible API server for the visualizer:

```powershell
rtk pwsh -NoProfile -ExecutionPolicy Bypass -File demo/scripts/start-graphrag-api.ps1
```

The script writes timestamped retrieval outputs under `demo/ic-memo/generated/`, which is ignored except for `.gitkeep`.

## Guardrail

The sample memo is a showcase draft, not investment advice. Do not let the model turn missing evidence into confident claims.
