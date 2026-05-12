# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
variable "tenancy_ocid" {
  description = "OCI tenancy OCID."
  type        = string
}

variable "compartment_ocid" {
  description = "Parent compartment OCID for resources managed by this module."
  type        = string
}

variable "region" {
  description = "OCI region name."
  type        = string
}

variable "org" {
  description = "Short organization prefix used in names."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "region_key" {
  description = "Short OCI region key used in resource names."
  type        = string
}

variable "cis_level" {
  description = "CIS OCI Benchmark profile for the landing zone. Use level1 for baseline controls or level2 for stricter controls."
  type        = string
  default     = null

  validation {
    condition     = var.cis_level == null ? true : contains(["level1", "level2"], lower(var.cis_level))
    error_message = "cis_level must be either level1 or level2."
  }
}

variable "defined_tags" {
  description = "Defined tags applied to resources."
  type        = map(string)
  default     = {}
}

variable "freeform_tags" {
  description = "Freeform tags applied to resources."
  type        = map(string)
  default     = {}
}

variable "root_compartment_name" {
  description = "Display name for the landing zone root compartment. Defaults to the standard naming prefix with cmp-root."
  type        = string
  default     = null
}

variable "root_compartment_description" {
  description = "Description for the landing zone root compartment."
  type        = string
  default     = "OCI landing zone root compartment managed by Terraform."
}

variable "enable_delete" {
  description = "Allow Terraform to delete created compartments during destroy. Keep true for ephemeral tests; review carefully for production."
  type        = bool
  default     = true
}

variable "child_compartments" {
  description = "Child compartments to create under the landing zone root compartment."
  type = map(object({
    description   = string
    enable_delete = optional(bool)
  }))
  default = {
    network = {
      description = "Networking resources such as VCNs, DRGs, DNS, and gateways."
    }
    security = {
      description = "Security resources such as Cloud Guard, Vault, Security Zones, VSS, and Bastion."
    }
    governance = {
      description = "Governance resources such as tags, budgets, logs, events, and notifications."
    }
    workloads = {
      description = "Workload and operating entity compartments."
    }
  }
}
