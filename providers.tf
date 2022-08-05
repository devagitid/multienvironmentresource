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

}

provider "databricks" {
azure_workspace_resource_id = azurerm_databricks_workspace.example.id
}
