terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
    databricks = {
      source = "databricks/databricks"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = "d2626169-7b5d-41d5-b3d0-137f693c4219"
  client_id       = "43840f06-e48c-47fb-a418-259fc299282a"
  client_secret   = "lsd8Q~0IfbYGuXKxvZMEKslLwUHRvl004MyzNdzm"
  tenant_id       = "5eef40ba-552a-49e3-be68-6805b66cf278"
}

provider "databricks" {
azure_workspace_resource_id = azurerm_databricks_workspace.example.id
}
