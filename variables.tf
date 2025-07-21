variable "location" {
  description = "The region where the resources are deployed"
  default     = "uksouth"
  type        = string
}

variable "subscription_id" {
  description = "The ID of the Azure Subscription"
  type        = string
}

variable "environment" {
  description = "Environment where the resources are deployed"
  default     = "demo"
  type        = string

  validation {
    condition     = contains(["demo", "dev", "staging", "prod"], var.environment)
    error_message = "Invalid value for environment. Allowed values are 'demo', 'dev', 'staging' or 'prod'"
  }
}

variable "extra_tags" {
  description = "Extra tags to set in resources"
  default     = {}
  type        = map(any)
}
