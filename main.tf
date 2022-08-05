terraform {
  backend azure {}
}

resource "azurerm_resource_group" "databrrg" {
name = "${var.environment}-rg"
location = var.resource_location
}

resource "azurerm_databricks_workspace" "databr" {
  name                = "databricks-${var.environment}"
  resource_group_name = azurerm_resource_group.databrrg.name
  location            = azurerm_resource_group.databrrg.location
  sku                 = "standard"

  tags = {
    Environment = var.environment
  }
}

data "databricks_node_type" "smallest" {
  local_disk = true
  depends_on = [azurerm_databricks_workspace.databr]
}

data "databricks_spark_version" "latest_lts" {
  long_term_support = true
  depends_on = [azurerm_databricks_workspace.databr]
}

resource "databricks_cluster" "multi_node" {
  cluster_name            = "Multi Node"
  spark_version           = data.databricks_spark_version.latest_lts.id
  node_type_id            = data.databricks_node_type.smallest.id
  autotermination_minutes = 20
  num_workers            = 2

  spark_conf = {
    # Multi-node
    "spark.databricks.cluster.profile" : "MultiNode"
    "spark.master" : "local[*]"
  }
  custom_tags = {
    "ResourceClass" = "MultiNode"
  }
depends_on = [azurerm_databricks_workspace.databr]
}

resource "azuread_application" "example" {
  display_name = "example"
  owners       = var.object_id
}

resource "azuread_service_principal" "example" {
  application_id               = azuread_application.example.application_id
  app_role_assignment_required = false
  owners                       = var.object_id
}

resource "azurerm_key_vault" "kv" {
  name                       = "${var.environment}keyvaultqw"
  location                   = azurerm_resource_group.databrrg.location
  resource_group_name        = azurerm_resource_group.databrrg.name
  tenant_id                  = var.tenant_id
  sku_name                   = "premium"
  soft_delete_retention_days = 7


  access_policy {

    tenant_id               = var.tenant_id
    object_id               = azuread_service_principal.example.object_id
    key_permissions         = ["Get", "List"]
    secret_permissions      = ["Get", "List"]
    certificate_permissions = ["Get", "Import", "List"]
    storage_permissions     = ["Backup", "Get", "List", "Recover"]

  }


}

resource "azurerm_key_vault_secret" "kv" {
  name         = "clientid"
  value        = azuread_service_principal.example.application_id 
  key_vault_id = azurerm_key_vault.kv.id
}
