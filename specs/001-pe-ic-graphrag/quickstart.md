# Quickstart: PE IC GraphRAG Showcase

## 1. Verify Spec Kit

```powershell
rtk specify check
```

## 2. Install App Dependencies

```powershell
rtk pnpm install
```

## 3. Prepare Public Demo Corpus

```powershell
rtk pwsh -NoProfile -ExecutionPolicy Bypass -File demo/scripts/prepare-forterro-corpus.ps1
```

Downloaded files are written under `demo/corpus/raw/` and `demo/corpus/text/`, both ignored by git.

## 4. Run Microsoft GraphRAG

Convert downloaded PDFs to Markdown. Preferred Azure Document Intelligence path:

```powershell
$env:AZURE_DOCUMENT_INTELLIGENCE_ENDPOINT = "<document-intelligence-endpoint>"
$env:AZURE_DOCUMENT_INTELLIGENCE_KEY = "<document-intelligence-key>"
rtk pwsh -NoProfile -ExecutionPolicy Bypass -File demo/scripts/convert-corpus-pdfs-with-document-intelligence.ps1
```

Local fallback:

```powershell
rtk pwsh -NoProfile -ExecutionPolicy Bypass -File demo/scripts/convert-corpus-pdfs-to-markdown.ps1
```

Use `demo/corpus/text/` as the source input folder for a Microsoft GraphRAG project. After indexing, copy the parquet artifacts into:

```text
public/artifacts/
```

For local indexing against Azure AI Foundry, prefer the retry wrapper:

```powershell
rtk pwsh -NoProfile -ExecutionPolicy Bypass -File demo/scripts/run-graphrag-index-with-retry.ps1 -ProjectRoot "<graphrag-project-root>"
```

Expected GraphRAG v2 names include `entities.parquet`, `relationships.parquet`, `documents.parquet`, `text_units.parquet`, `communities.parquet`, `community_reports.parquet`, and optional `covariates.parquet`.

## 5. Run Search API and Visualizer

Start `graphrag-api` for the same GraphRAG project, then run:

```powershell
rtk pnpm start
```

Open the app, load artifacts, and test Local, Global, and Drift Search.

## 6. Build IC Memo

Use `demo/ic-memo/question-catalogue.json` to run section-level retrieval prompts. Copy retrieved evidence into `demo/ic-memo/sample-forterro-ic-memo.md`, preserving evidence references, assumptions, and open diligence gaps.

With `graphrag-api` running:

```powershell
$env:GRAPHRAG_API_URL = "http://localhost:8000"
rtk pwsh -NoProfile -ExecutionPolicy Bypass -File demo/scripts/run-ic-question-catalogue.ps1
```
