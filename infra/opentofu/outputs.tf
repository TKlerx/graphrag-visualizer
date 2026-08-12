output "resource_group_name" {
  description = "Azure resource group name."
  value       = azurerm_resource_group.main.name
}

output "foundry_resource_name" {
  description = "Microsoft Foundry resource name."
  value       = azapi_resource.foundry.name
}

output "foundry_project_name" {
  description = "Microsoft Foundry project name."
  value       = azapi_resource.foundry_project.name
}

output "foundry_endpoint" {
  description = "Foundry endpoint for GraphRAG configuration."
  value       = azapi_resource.foundry.output.properties.endpoint
}

output "chat_model_deployment_name" {
  description = "Chat model deployment name for GraphRAG."
  value       = local.graph_chat_deployment_name
}

output "fallback_chat_model_deployment_name" {
  description = "Fallback chat model deployment name."
  value       = azapi_resource.chat_deployment.name
}

output "embedding_model_deployment_name" {
  description = "Embedding model deployment name for GraphRAG."
  value       = azapi_resource.embedding_deployment.name
}

output "document_intelligence_endpoint" {
  description = "Azure AI Document Intelligence endpoint for PDF-to-Markdown conversion."
  value       = azurerm_cognitive_account.document_intelligence.endpoint
}

output "document_intelligence_primary_key" {
  description = "Azure AI Document Intelligence primary key. Store securely and do not commit."
  value       = azurerm_cognitive_account.document_intelligence.primary_access_key
  sensitive   = true
}

output "storage_account_name" {
  description = "Storage account for corpus and GraphRAG artifacts."
  value       = azurerm_storage_account.main.name
}

output "corpus_container_name" {
  description = "Blob container for corpus input files."
  value       = azurerm_storage_container.corpus.name
}

output "artifacts_container_name" {
  description = "Blob container for GraphRAG parquet artifacts."
  value       = azurerm_storage_container.artifacts.name
}

output "container_registry_login_server" {
  description = "ACR login server for custom GraphRAG/API images."
  value       = azurerm_container_registry.main.login_server
}

output "api_url" {
  description = "Container App URL for the GraphRAG API."
  value       = var.deploy_api_container_app ? "https://${azurerm_container_app.api[0].latest_revision_fqdn}" : null
}

output "static_web_app_default_host_name" {
  description = "Static Web App default host name."
  value       = var.deploy_static_web_app ? azurerm_static_web_app.visualizer[0].default_host_name : null
}
