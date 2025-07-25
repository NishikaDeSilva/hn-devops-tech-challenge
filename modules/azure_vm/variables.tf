variable "location" {
  description = "The region where the resources are deployed"
  type        = string
  default     = "uksouth"
}

variable "resource_group_name" {
  description = "Name of the resource group that the resources are deployed"
  type        = string
}

variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string
}

variable "vm_size" {
  description = "The SKU to be used for this virtual machine"
  type        = string
  default     = "Standard_B1s"
}

variable "vm_admin_user" {
  description = "Username of the local admin for this virtual machine"
  type        = string
  default     = "adminuser"
}

variable "subnet_id" {
  description = "The ID of the subnet where the Network interface located"
  type        = string
}

variable "rsa_public_key" {
  description = "The Public Key which should be used for authentication"
  type        = string
  sensitive   = true
}

variable "enable_public_access" {
  description = "Set true if public access is enabled"
  default     = false
  type        = bool
}

variable "nsg_source_address_prefix" {
  description = "Source IP addresses to allow SSH into VM"
  type        = list(string)
}

variable "cloud_init_script" {
  description = "Cloud init script to be added to VM"
  type        = string
  sensitive   = true
  default     = ""
}

variable "tags" {
  description = "Tags to be added in resources"
  type        = map(any)
  default     = {}
}
