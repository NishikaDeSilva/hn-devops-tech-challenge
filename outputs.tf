output "vm_0_private_ip_address" {
  value = module.private_vm.0.vm_ip_address
}

output "vm_1_private_ip_address" {
  value = module.private_vm.1.vm_ip_address
}

output "jumpbox_public_ip" {
  value = module.jumpbox_vm.vm_ip_address
}
