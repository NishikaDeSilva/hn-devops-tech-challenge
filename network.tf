resource "azurerm_virtual_network" "az_vnet" {
  name                = module.naming.virtual_network.name
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.az_resource_group.name
}

resource "azurerm_subnet" "az_pvt_subnet" {
  name                 = "${module.naming.subnet.name}-private"
  resource_group_name  = azurerm_resource_group.az_resource_group.name
  virtual_network_name = azurerm_virtual_network.az_vnet.name
  address_prefixes     = [local.private_sn_ip_range]
}

resource "azurerm_subnet" "az_pub_subnet" {
  name                 = "${module.naming.subnet.name}-public"
  resource_group_name  = azurerm_resource_group.az_resource_group.name
  virtual_network_name = azurerm_virtual_network.az_vnet.name
  address_prefixes     = [local.public_sn_ip_range]
}
