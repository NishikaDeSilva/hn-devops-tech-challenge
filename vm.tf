
module "private_vm" {
  source = "./modules/azure_vm"

  count               = 2
  resource_group_name = azurerm_resource_group.az_resource_group.name
  subnet_id           = azurerm_subnet.az_pvt_subnet.id
  vm_name             = "${module.naming.virtual_machine.name}-${count.index}"
  rsa_public_key      = file(".ssh/hn_rsa.pub")
}

