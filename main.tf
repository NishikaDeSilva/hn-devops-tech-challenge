## This module is used to generate a consistent naming convention for Azure resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"
  suffix  = [lower(substr(var.location, 0, 3)), var.environment]
}

locals {
  tags = merge({
    env    = var.environment,
    region = var.location
  }, var.extra_tags)
}

resource "azurerm_resource_group" "az_resource_group" {
  name     = module.naming.resource_group.name
  location = var.location
  tags     = local.tags
}
