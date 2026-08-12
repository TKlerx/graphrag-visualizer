# PE/IC Prompt Pack

These prompts are lightweight domain adapters for Microsoft GraphRAG. Use them as starting points after running `graphrag init`.

Recommended setup:

1. Copy `demo/graphrag/settings.azure-foundry.yml` into your GraphRAG project root as `settings.yml`.
2. Copy this `prompts/` folder into the GraphRAG project root.
3. Copy `demo/graphrag/.env.azure-foundry.example` into the GraphRAG project root as `.env` and fill the Azure AI Foundry values.
4. Run GraphRAG indexing.

These prompts are intentionally conservative. They bias extraction toward investment committee concepts without forcing unsupported financial claims.
