# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
variable "tenancy_ocid" {
  description = "OCI tenancy OCID."
  type        = string
}

variable "current_user_ocid" {
  description = "OCI user OCID used for local execution or bootstrap."
  type        = string
  default     = null
}

variable "region" {
  description = "OCI region name."
  type        = string
}

variable "home_region" {
  description = "OCI tenancy home region."
  type        = string
  default     = null
}

variable "oci_config_profile" {
  description = "Optional OCI CLI config profile for local execution."
  type        = string
  default     = null
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

variable "parent_compartment_ocid" {
  description = "Default parent compartment OCID where operating entity root compartments are created. Defaults to tenancy_ocid."
  type        = string
  default     = null
}

variable "enable_delete" {
  description = "Allow Terraform to delete created operating entity compartments during destroy."
  type        = bool
  default     = true
}

variable "default_workload_compartments" {
  description = "Default child compartments created under each operating entity root when not overridden per entity."
  type = map(object({
    description   = string
    enable_delete = optional(bool)
  }))
  default = {
    platform = {
      description = "Shared platform resources for the operating entity."
    }
    workloads = {
      description = "Application and workload resources for the operating entity."
    }
    security = {
      description = "Security resources scoped to the operating entity."
    }
  }
}

variable "operating_entities" {
  description = "Operating entities keyed by stable logical name."
  type = map(object({
    code                    = optional(string)
    name                    = optional(string)
    parent_compartment_ocid = optional(string)
    policy_compartment_ocid = optional(string)
    root_compartment_name   = optional(string)
    admin_group_name        = optional(string)
    auditor_group_name      = optional(string)
    workload_compartments = optional(map(object({
      description   = string
      enable_delete = optional(bool)
    })))
  }))
  default = {
    finance = {
      code = "fin"
      name = "Finance"
    }
    engineering = {
      code = "eng"
      name = "Engineering"
    }
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
