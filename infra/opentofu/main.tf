locals {
  normalized_prefix = replace(var.prefix, "-", "")
  unique_prefix     = substr("${local.normalized_prefix}${random_string.unique.result}", 0, 18)
  graph_chat_deployment_name = (
    var.deploy_preferred_chat_model
    ? azapi_resource.preferred_chat_deployment[0].name
    : azapi_resource.chat_deployment.name
  )

  tags = merge(
    {
      project     = "graphrag-visualizer"
      workload    = "pe-ic-demo"
      environment = var.environment
      managed_by  = "opentofu"
    },
    var.tags
  )
}

resource "random_string" "unique" {
  length  = 5
  numeric = true
  special = false
  lower   = true
  upper   = false
}

resource "azurerm_resource_group" "main" {
  name     = coalesce(var.resource_group_name, "rg-${var.prefix}-${random_string.unique.result}")
  location = var.location
  tags     = local.tags
}

resource "azurerm_log_analytics_workspace" "main" {
  name                = "log-${var.prefix}-${random_string.unique.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.tags
}

resource "azurerm_storage_account" "main" {
  name                            = substr("st${local.unique_prefix}", 0, 24)
  location                        = azurerm_resource_group.main.location
  resource_group_name             = azurerm_resource_group.main.name
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false
  min_tls_version                 = "TLS1_2"
  tags                            = local.tags
}

resource "azurerm_storage_container" "corpus" {
  name                  = "corpus"
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "artifacts" {
  name                  = "graphrag-artifacts"
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = "private"
}

resource "azurerm_container_registry" "main" {
  name                = substr("acr${local.unique_prefix}", 0, 50)
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"
  admin_enabled       = false
  tags                = local.tags
}

resource "azurerm_cognitive_account" "document_intelligence" {
  name                          = "docint-${var.prefix}-${random_string.unique.result}"
  location                      = azurerm_resource_group.main.location
  resource_group_name           = azurerm_resource_group.main.name
  kind                          = "FormRecognizer"
  sku_name                      = var.document_intelligence_sku_name
  custom_subdomain_name         = "docint-${var.prefix}-${random_string.unique.result}"
  public_network_access_enabled = true
  tags                          = local.tags
}

resource "azapi_resource" "foundry" {
  type                      = "Microsoft.CognitiveServices/accounts@2025-06-01"
  name                      = "foundry-${var.prefix}-${random_string.unique.result}"
  parent_id                 = azurerm_resource_group.main.id
  location                  = azurerm_resource_group.main.location
  schema_validation_enabled = false

  body = {
    kind = "AIServices"
    sku = {
      name = "S0"
    }
    identity = {
      type = "SystemAssigned"
    }
    properties = {
      allowProjectManagement = true
      customSubDomainName    = "foundry-${var.prefix}-${random_string.unique.result}"
      disableLocalAuth       = false
    }
  }

  tags = local.tags
}

resource "azapi_resource" "foundry_project" {
  type                      = "Microsoft.CognitiveServices/accounts/projects@2025-06-01"
  name                      = "proj-${var.prefix}"
  parent_id                 = azapi_resource.foundry.id
  location                  = azurerm_resource_group.main.location
  schema_validation_enabled = false

  body = {
    sku = {
      name = "S0"
    }
    identity = {
      type = "SystemAssigned"
    }
    properties = {
      displayName = "PE IC GraphRAG Showcase"
      description = "Azure AI Foundry project for GraphRAG-based investment committee memo preparation demo."
    }
  }
}

resource "azapi_resource" "chat_deployment" {
  type      = "Microsoft.CognitiveServices/accounts/deployments@2023-05-01"
  name      = var.chat_model_name
  parent_id = azapi_resource.foundry.id

  body = {
    sku = {
      name     = "GlobalStandard"
      capacity = var.chat_model_capacity
    }
    properties = {
      model = {
        format  = "OpenAI"
        name    = var.chat_model_name
        version = var.chat_model_version
      }
    }
  }
}

resource "azapi_resource" "preferred_chat_deployment" {
  count     = var.deploy_preferred_chat_model ? 1 : 0
  type      = "Microsoft.CognitiveServices/accounts/deployments@2023-05-01"
  name      = var.preferred_chat_model_name
  parent_id = azapi_resource.foundry.id
  depends_on = [
    azapi_resource.chat_deployment
  ]

  body = {
    sku = {
      name     = "GlobalStandard"
      capacity = var.preferred_chat_model_capacity
    }
    properties = {
      model = {
        format  = "OpenAI"
        name    = var.preferred_chat_model_name
        version = var.preferred_chat_model_version
      }
    }
  }
}

resource "azapi_resource" "embedding_deployment" {
  type      = "Microsoft.CognitiveServices/accounts/deployments@2023-05-01"
  name      = var.embedding_model_name
  parent_id = azapi_resource.foundry.id
  depends_on = [
    azapi_resource.chat_deployment,
    azapi_resource.preferred_chat_deployment,
    azapi_resource.foundry_project
  ]

  body = {
    sku = {
      name     = "GlobalStandard"
      capacity = var.embedding_model_capacity
    }
    properties = {
      model = {
        format  = "OpenAI"
        name    = var.embedding_model_name
        version = var.embedding_model_version
      }
    }
  }
}

resource "azurerm_container_app_environment" "main" {
  name                       = "cae-${var.prefix}-${random_string.unique.result}"
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  tags                       = local.tags
}

resource "azurerm_container_app" "api" {
  count                        = var.deploy_api_container_app ? 1 : 0
  name                         = "ca-${var.prefix}-api"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"
  tags                         = local.tags

  identity {
    type = "SystemAssigned"
  }

  ingress {
    external_enabled = true
    target_port      = var.api_target_port

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  template {
    min_replicas = 0
    max_replicas = 2

    container {
      name   = "graphrag-api"
      image  = var.api_container_image
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "AZURE_AI_FOUNDRY_ENDPOINT"
        value = azapi_resource.foundry.output.properties.endpoint
      }

      env {
        name  = "GRAPHRAG_CHAT_DEPLOYMENT"
        value = local.graph_chat_deployment_name
      }

      env {
        name  = "GRAPHRAG_EMBEDDING_DEPLOYMENT"
        value = var.embedding_model_name
      }

      env {
        name  = "GRAPHRAG_STORAGE_ACCOUNT"
        value = azurerm_storage_account.main.name
      }

      env {
        name  = "AZURE_DOCUMENT_INTELLIGENCE_ENDPOINT"
        value = azurerm_cognitive_account.document_intelligence.endpoint
      }
    }
  }
}

resource "azurerm_static_web_app" "visualizer" {
  count               = var.deploy_static_web_app ? 1 : 0
  name                = "swa-${var.prefix}-${random_string.unique.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.static_web_app_location
  sku_tier            = "Free"
  sku_size            = "Free"
  tags                = local.tags
}
