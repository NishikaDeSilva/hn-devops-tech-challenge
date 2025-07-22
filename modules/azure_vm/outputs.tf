output "vm_ip_address" {
  description = "IP address of the VM"
  value       = var.enable_public_access ? azurerm_public_ip.az_pip.0.ip_address : azurerm_network_interface.az_nic.private_ip_address
}

output "vm_id" {
  description = "ID if the Virtual Machine"
  value       = azurerm_linux_virtual_machine.az_linux_vm.id
}
