output "vm_0_private_ip_address" {
  description = "Private IP address of the Virtual Machine - 1"
  value       = module.private_vm.0.vm_ip_address
}

output "vm_1_private_ip_address" {
  description = "Private IP address of the Virtual Machine - 2"
  value       = module.private_vm.1.vm_ip_address
}

output "jumpbox_public_ip" {
  description = "Public IP address of the Jumpbox"
  value       = module.jumpbox_vm.vm_ip_address
}

output "resource_group_name" {
  description = "Name of the resource group for resources"
  value       = azurerm_resource_group.az_resource_group.name
}

output "storage_account_name" {
  description = "Name of the Storage Account"
  value       = azurerm_storage_account.az_storage.name
}
