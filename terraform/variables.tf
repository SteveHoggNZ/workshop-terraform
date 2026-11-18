variable "workload" {
  description = "Short workload name used in resource names."
  type        = string
  default     = "poc"

  validation {
    condition     = can(regex("^[a-z0-9]{2,6}$", var.workload))
    error_message = "workload must be 2-6 lowercase alphanumeric characters."
  }
}

variable "environment" {
  description = "Deployment environment."
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be one of: dev, prod."
  }
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "australiaeast"

  validation {
    condition     = contains(["australiaeast", "australiasoutheast"], var.location)
    error_message = "location must be australiaeast or australiasoutheast."
  }
}

variable "instance" {
  description = "Instance number suffix for resource names."
  type        = number
  default     = 1
}

variable "tiers" {
  description = "Application tiers keyed by short tier name."
  type = map(object({
    vm_count = number
  }))

  validation {
    condition     = alltrue([for k, t in var.tiers : can(regex("^[a-z]{3}$", k)) && t.vm_count >= 1 && t.vm_count <= 99])
    error_message = "Tier keys must be 3 lowercase letters and vm_count must be 1-99."
  }
}

variable "tags" {
  description = "Additional tags. Mandatory tags cannot be overridden."
  type        = map(string)
  default     = {}
}
