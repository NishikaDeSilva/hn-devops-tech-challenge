output "vm_private_ip_address" {
  description = "Private IP address of the VM"
  value       = azurerm_network_interface.az_nic.private_ip_address
}