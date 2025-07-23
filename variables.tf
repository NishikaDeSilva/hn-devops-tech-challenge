variable "location" {
  description = "The region where the resources are deployed"
  type        = string
  default     = "uksouth"
}

variable "subscription_id" {
  description = "The ID of the Azure Subscription"
  type        = string
}


variable "environment" {
  description = "Environment where the resources are deployed"
  type        = string
  default     = "demo"

  validation {
    condition     = contains(["demo", "dev", "staging", "prod"], var.environment)
    error_message = "Invalid value for environment. Allowed values are 'demo', 'dev', 'staging' or 'prod'"
  }
}

variable "jumpbox_allow_ips" {
  description = "IP range to allow access to jumpbox host"
  type        = list(string)
}

variable "ssh_public_key_file_path" {
  description = "File path to the public SSH key used for VM access"
  type        = string
}

variable "tenant_id" {
  description = "Azure Tenant ID. Required for Identity and Access Management"
  type        = string
  default     = ""
}

variable "entra_ssh_enabled" {
  description = "Set true to enable SSH login with Entra ID"
  type        = bool
  default     = false
}

variable "entra_id_users" {
  description = "List of entra ID users to be created"
  type        = list(string)
  default     = []
}

variable "extra_tags" {
  description = "Extra tags to set in resources"
  type        = map(any)
  default     = {}
}

