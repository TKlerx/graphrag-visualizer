# Azure AI Foundry OpenTofu Deployment

This OpenTofu scaffold provisions the Azure resources needed for the PE IC GraphRAG showcase:

- Resource group
- Microsoft Foundry account and project
- Foundry model deployments for chat and embeddings
- Azure AI Document Intelligence for PDF-to-Markdown extraction
- Storage account with containers for corpus input and GraphRAG artifacts
- Azure Container Registry for optional GraphRAG/API images
- Log Analytics and Container Apps environment
- Optional Container App for `graphrag-api`
- Optional Static Web App shell for the visualizer frontend

The graph build remains a Microsoft GraphRAG indexing workflow. Azure AI Foundry supplies the chat and embedding deployments used by GraphRAG, while GraphRAG writes parquet artifacts that can be loaded into the visualizer.

The default preferred chat deployment is `gpt-5.4` with `gpt-4o` retained as fallback. `gpt-5.5` is catalog-visible in Sweden Central but may require an explicit quota increase before deployment.

## Prerequisites

- OpenTofu
- Azure CLI login: `az login`
- Azure subscription with permission to create Microsoft Foundry resources
- Foundry/Azure OpenAI model quota in the selected region

Microsoft's current Terraform guidance for Foundry uses `Microsoft.CognitiveServices/accounts@2025-06-01` with `kind = "AIServices"` and `allowProjectManagement = true`. The official docs also note that AzAPI covers more Foundry control-plane features than AzureRM.

## Usage

```powershell
cd infra/opentofu
tofu init
tofu plan -out main.tfplan `
  -var "subscription_id=<azure-subscription-id>" `
  -var "location=swedencentral" `
  -var "prefix=pg-tk-test" `
  -var "resource_group_name=proj-pg-tk-test" `
  -var "static_web_app_location=westeurope" `
  -var "deploy_static_web_app=false" `
  -var "deploy_api_container_app=false"
tofu apply main.tfplan
```

## Build the Graph

1. Prepare the public corpus:

   ```powershell
   rtk pwsh -NoProfile -ExecutionPolicy Bypass -File demo/scripts/prepare-forterro-corpus.ps1
   ```

2. Convert PDFs to Markdown. Prefer Document Intelligence for table/layout-heavy reports:

   ```powershell
   $env:AZURE_DOCUMENT_INTELLIGENCE_ENDPOINT = "$(tofu output -raw document_intelligence_endpoint)"
   $env:AZURE_DOCUMENT_INTELLIGENCE_KEY = "$(tofu output -raw document_intelligence_primary_key)"
   rtk pwsh -NoProfile -ExecutionPolicy Bypass -File ../../demo/scripts/convert-corpus-pdfs-with-document-intelligence.ps1
   ```

   Use `demo/scripts/convert-corpus-pdfs-to-markdown.ps1` as the local fallback when Azure is unavailable.

3. Upload corpus files to the provisioned storage container or use them locally.

4. Configure Microsoft GraphRAG to use the Foundry outputs:

   - Chat deployment: `chat_model_deployment_name`
   - Embedding deployment: `embedding_model_deployment_name`
   - Endpoint: `foundry_endpoint`

5. Run GraphRAG indexing.

6. Copy the generated parquet files into `public/artifacts/` for local visualization or upload them to the `graphrag-artifacts` storage container for the deployed workflow.

## Deploy the App

This scaffold creates the Azure resources and emits deployment outputs. It does not build/push custom container images. For the API container, build an image for `graphrag-api`, push it to the provisioned ACR, then set:

```powershell
tofu apply `
  -var "subscription_id=<azure-subscription-id>" `
  -var "api_container_image=<acr-login-server>/<image>:<tag>"
```

For the visualizer, build the React app and connect your deployment pipeline to the Static Web App resource output.

## State and Secrets

The default backend is local for demo ergonomics. For shared work, configure a remote encrypted state backend before applying. Do not commit `.tfvars`, state files, or downloaded corpus documents.
