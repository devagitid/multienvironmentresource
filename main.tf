terraform {
  backend azure {}
}

resource "azurerm_resource_group" "databrrg" {
name = "$var.environment-rg"
location = var.resource_location
}

