# Azure AI Foundry Graph Build

## Recommended Architecture

Build the graph with Microsoft GraphRAG, but configure GraphRAG to use Azure AI Foundry model deployments for chat and embeddings.

```text
Public/internal documents
        ↓
Corpus preparation + Document Intelligence PDF extraction
        ↓
Microsoft GraphRAG indexing
        ↓
Azure AI Foundry chat + embedding deployments
        ↓
GraphRAG parquet artifacts
        ↓
Visualizer + graphrag-api
        ↓
IC question catalogue and Markdown memo
```

This keeps the data product aligned with the current visualizer: Microsoft GraphRAG writes parquet tables such as `entities.parquet`, `relationships.parquet`, `text_units.parquet`, `communities.parquet`, and `community_reports.parquet`.

## Azure Resources

The OpenTofu scaffold in `infra/opentofu/` provisions:

- Microsoft Foundry resource and project.
- Chat and embedding model deployments.
- Azure AI Document Intelligence for PDF-to-Markdown extraction.
- Storage containers for corpus files and GraphRAG artifacts.
- ACR for custom GraphRAG/API images.
- Container Apps environment and optional API app.
- Optional Static Web App shell for the frontend visualizer.

## Build Steps

1. Deploy Azure resources with OpenTofu:

   ```powershell
   cd infra/opentofu
   tofu init
   tofu plan -out main.tfplan -var "subscription_id=<subscription-id>"
   tofu apply main.tfplan
   tofu output
   ```

2. Prepare the Forterro public corpus:

   ```powershell
   rtk pwsh -NoProfile -ExecutionPolicy Bypass -File demo/scripts/prepare-forterro-corpus.ps1
   ```

3. Convert PDFs to Markdown.

   Preferred Azure path:

   ```powershell
   $env:AZURE_DOCUMENT_INTELLIGENCE_ENDPOINT = "<document-intelligence-endpoint>"
   $env:AZURE_DOCUMENT_INTELLIGENCE_KEY = "<document-intelligence-key>"
   rtk pwsh -NoProfile -ExecutionPolicy Bypass -File demo/scripts/convert-corpus-pdfs-with-document-intelligence.ps1
   ```

   Local fallback:

   ```powershell
   rtk pwsh -NoProfile -ExecutionPolicy Bypass -File demo/scripts/convert-corpus-pdfs-to-markdown.ps1
   ```

4. Use `demo/corpus/text/` as the GraphRAG source folder. Markdown files are plain text and can be indexed as text inputs; include `.md` in your input pattern if your GraphRAG config filters extensions.

5. Configure Microsoft GraphRAG with the OpenTofu outputs:

   - `foundry_endpoint`
   - `chat_model_deployment_name`
   - `embedding_model_deployment_name`

   Use `demo/graphrag/settings.azure-foundry.yml` and `demo/graphrag/.env.azure-foundry.example` as starting templates. Copy the PE/IC prompt pack from `demo/graphrag/prompts/` into the GraphRAG project.

6. Run GraphRAG indexing locally, in CI, or in a custom container job.

   For local runs, use the retry wrapper so transient Azure OpenAI rate-limit or TPM responses pause and retry the index:

   ```powershell
   rtk pwsh -NoProfile -ExecutionPolicy Bypass -File demo/scripts/run-graphrag-index-with-retry.ps1 -ProjectRoot "<graphrag-project-root>"
   ```

7. Put parquet artifacts in `public/artifacts/` for local demos, or upload them to the `graphrag-artifacts` Azure Storage container.

8. Run `graphrag-api` against the same GraphRAG output and set the visualizer's `REACT_APP_API_URL` to the API URL.

9. Run the IC question catalogue against `graphrag-api`:

   ```powershell
   $env:GRAPHRAG_API_URL = "<api-url>"
   rtk pwsh -NoProfile -ExecutionPolicy Bypass -File demo/scripts/run-ic-question-catalogue.ps1
   ```

## DRIFT Search Tuning

GraphRAG v3 DRIFT defaults are optimized for broad exploration and can be slow for an interactive demo. The default search may select many community reports, generate many follow-up actions, and run several rounds of local search. For this PE IC showcase, `demo/graphrag/settings.azure-foundry.yml` uses a narrower DRIFT profile:

- `drift_k_followups: 4`
- `n_depth: 1`
- `primer_folds: 2`
- `local_search_top_k_mapped_entities: 5`
- `local_search_top_k_relationships: 5`
- `local_search_max_data_tokens: 6000`

This keeps DRIFT useful as a follow-up discovery mode while avoiding long-running query sessions and oversized local-search contexts.

## Notes

- Keep downloaded source documents and Terraform state out of git.
- The included Container App starts with a placeholder image. Replace `api_container_image` after you build and push a real `graphrag-api` image.
- For production use, add private networking, managed identity data-plane permissions, remote state, and enterprise policy controls.
