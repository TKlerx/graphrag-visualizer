# Forterro PE IC Demo Corpus

This folder contains only metadata and instructions for a public proxy corpus. Downloaded third-party documents are intentionally ignored by git.

## Purpose

The corpus is meant to mimic the mix Partners Group described: internal prior investment knowledge, recent investment context, and current market data. For the first showcase, Forterro is the anchor company because public materials cover the sponsor thesis, company positioning, transaction context, and private equity market backdrop.

## Local Folders

Running the preparation script creates:

```text
demo/corpus/raw/
demo/corpus/text/
```

Both folders are ignored. Use `demo/corpus/text/` as a starting input folder for Microsoft GraphRAG indexing.

## Build

```powershell
rtk pwsh -NoProfile -ExecutionPolicy Bypass -File demo/scripts/prepare-forterro-corpus.ps1
```

The script downloads each URL in `manifest.json`. HTML pages also get a basic text extraction. PDFs are kept as raw files; convert them to text with your preferred PDF extraction step before GraphRAG indexing if your GraphRAG pipeline does not ingest PDFs directly.

## PDF to Markdown

Microsoft GraphRAG ingests text-oriented source formats. Treat PDFs as source documents that need conversion before indexing.

For the best extraction quality, especially tables and report layout, use Azure AI Document Intelligence:

```powershell
$env:AZURE_DOCUMENT_INTELLIGENCE_ENDPOINT = "<document-intelligence-endpoint>"
$env:AZURE_DOCUMENT_INTELLIGENCE_KEY = "<document-intelligence-key>"
rtk pwsh -NoProfile -ExecutionPolicy Bypass -File demo/scripts/convert-corpus-pdfs-with-document-intelligence.ps1
```

If Azure is unavailable, use the local fallback:

```powershell
rtk pwsh -NoProfile -ExecutionPolicy Bypass -File demo/scripts/convert-corpus-pdfs-to-markdown.ps1
```

Both scripts write Markdown files to `demo/corpus/text/` with frontmatter containing the original source URL and demo purpose. Generated Markdown files are ignored by git together with the rest of `demo/corpus/text/`.

If your GraphRAG input configuration only includes `.txt` files, either include `.md` in the text input pattern or convert the generated Markdown files to `.txt`.

## Source URL Checklist

See `download-urls.md` for the exact URLs and expected local filenames.
