variable "subscription_id" {
  description = "Azure subscription ID."
  type        = string
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "westeurope"
}

variable "static_web_app_location" {
  description = "Azure region for Static Web Apps. Static Web Apps is not available in all regions."
  type        = string
  default     = "westeurope"
}

variable "deploy_static_web_app" {
  description = "Whether to create an Azure Static Web App for hosting the visualizer frontend."
  type        = bool
  default     = false
}

variable "prefix" {
  description = "Short lowercase prefix used for Azure resource names."
  type        = string
  default     = "pg-ic-demo"

  validation {
    condition     = can(regex("^[a-z0-9-]{3,20}$", var.prefix))
    error_message = "Use 3-20 lowercase letters, numbers, or hyphens."
  }
}

variable "resource_group_name" {
  description = "Exact Azure resource group name to create/use for the showcase resources. Defaults to a generated rg-{prefix}-{suffix} name."
  type        = string
  default     = null
}

variable "environment" {
  description = "Deployment environment tag."
  type        = string
  default     = "demo"
}

variable "chat_model_name" {
  description = "Foundry chat model deployment model name."
  type        = string
  default     = "gpt-4o"
}

variable "chat_model_version" {
  description = "Foundry chat model version."
  type        = string
  default     = "2024-11-20"
}

variable "chat_model_capacity" {
  description = "Chat deployment capacity."
  type        = number
  default     = 1
}

variable "deploy_preferred_chat_model" {
  description = "Whether to deploy the preferred GraphRAG chat model alongside the fallback chat deployment."
  type        = bool
  default     = true
}

variable "preferred_chat_model_name" {
  description = "Preferred Foundry chat model deployment model name for GraphRAG."
  type        = string
  default     = "gpt-5.4"
}

variable "preferred_chat_model_version" {
  description = "Preferred Foundry chat model version."
  type        = string
  default     = "2026-03-05"
}

variable "preferred_chat_model_capacity" {
  description = "Preferred chat deployment capacity."
  type        = number
  default     = 100
}

variable "embedding_model_name" {
  description = "Foundry embedding model deployment model name."
  type        = string
  default     = "text-embedding-3-large"
}

variable "embedding_model_version" {
  description = "Foundry embedding model version."
  type        = string
  default     = "1"
}

variable "embedding_model_capacity" {
  description = "Embedding deployment capacity."
  type        = number
  default     = 100
}

variable "document_intelligence_sku_name" {
  description = "Document Intelligence SKU."
  type        = string
  default     = "S0"
}

variable "api_container_image" {
  description = "Container image for graphrag-api. Leave default placeholder until your image is pushed."
  type        = string
  default     = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
}

variable "deploy_api_container_app" {
  description = "Whether to create the graphrag-api Container App. Keep false until a real API image is available."
  type        = bool
  default     = false
}

variable "api_target_port" {
  description = "Target port exposed by the graphrag-api container."
  type        = number
  default     = 8000
}

variable "tags" {
  description = "Additional Azure tags."
  type        = map(string)
  default     = {}
}
