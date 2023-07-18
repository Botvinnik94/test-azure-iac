terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.12.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
  }

  backend "azurerm" {}
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  skip_provider_registration = true
}

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = "West Europe"
}

resource "azurerm_storage_account" "storacc" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication
}

resource "azurerm_storage_container" "file_container" {
  name                  = var.storage_container_name
  storage_account_name  = azurerm_storage_account.storacc.name
  container_access_type = "blob"
}

resource "azurerm_storage_blob" "file" {
  access_tier            = "Hot"
  content_type           = "text/plain"
  name                   = "hello-world.txt"
  source                 = "../resources/hello-world.txt"
  storage_account_name   = azurerm_storage_account.storacc.name
  storage_container_name = azurerm_storage_container.file_container.name
  type                   = "Block"
}

resource "random_uuid" "role_assignment_blob_storage_id" {}

resource "azurerm_role_assignment" "func_role_storacc" {
  name                 = random_uuid.role_assignment_blob_storage_id.result
  scope                = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${azurerm_resource_group.rg.name}/providers/Microsoft.Storage/storageAccounts/${azurerm_storage_account.storacc.name}"
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_linux_function_app.func.identity[0].principal_id
}

resource "azurerm_service_plan" "srvplan" {
  name                = var.service_plan_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = var.service_plan_sku
}

resource "azurerm_linux_function_app" "func" {
  name                = var.function_app_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  storage_account_name       = azurerm_storage_account.storacc.name
  storage_account_access_key = azurerm_storage_account.storacc.primary_access_key
  service_plan_id            = azurerm_service_plan.srvplan.id

  site_config {
    always_on = var.function_app_always_on
    application_stack {
      python_version = "3.8"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [app_settings]
  }
}