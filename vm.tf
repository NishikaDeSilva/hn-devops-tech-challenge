
module "private_vm" {
  source = "./modules/azure_vm"

  count                     = 2
  resource_group_name       = azurerm_resource_group.az_resource_group.name
  subnet_id                 = azurerm_subnet.az_pvt_subnet.id
  vm_name                   = "${module.naming.virtual_machine.name}-${count.index}"
  rsa_public_key            = file(var.ssh_public_key_file_path)
  nsg_source_address_prefix = [local.public_sn_ip_range]
  cloud_init_script         = var.entra_ssh_enabled ? file("files/cloud-init.yml") : ""
  tags                      = local.tags
}

module "jumpbox_vm" {
  source = "./modules/azure_vm"

  resource_group_name       = azurerm_resource_group.az_resource_group.name
  subnet_id                 = azurerm_subnet.az_pub_subnet.id
  vm_name                   = "${module.naming.virtual_machine.name}-jumpbox"
  enable_public_access      = true
  rsa_public_key            = file(var.ssh_public_key_file_path)
  nsg_source_address_prefix = var.jumpbox_allow_ips
  tags                      = local.tags
}

resource "azurerm_virtual_machine_extension" "vm_extentions" {
  count                = var.entra_ssh_enabled ? 1 : 0
  name                 = "jumpbox-vm-extention"
  virtual_machine_id   = module.jumpbox_vm.vm_id
  publisher            = "Microsoft.Azure.ActiveDirectory"
  type                 = "AADSSHLoginForLinux"
  type_handler_version = "1.0"
}
