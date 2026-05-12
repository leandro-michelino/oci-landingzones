# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
variable "tenancy_ocid" {
  description = "OCI tenancy OCID."
  type        = string
}

variable "current_user_ocid" {
  description = "OCI user OCID used for local execution or bootstrap."
  type        = string
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
  description = "Parent compartment OCID where the operating entity root compartment is created. Defaults to tenancy_ocid for simple tests."
  type        = string
  default     = null
}

variable "entity_code" {
  description = "Short operating entity code used in names, for example fin, hr, app1, or latam."
  type        = string
  default     = "entity"
}

variable "entity_name" {
  description = "Human-readable operating entity name."
  type        = string
  default     = null
}

variable "root_compartment_name" {
  description = "Optional operating entity root compartment display name."
  type        = string
  default     = null
}

variable "root_compartment_description" {
  description = "Description for the operating entity root compartment."
  type        = string
  default     = "Operating entity root compartment managed by Terraform."
}

variable "enable_delete" {
  description = "Allow Terraform to delete created operating entity compartments during destroy."
  type        = bool
  default     = true
}

variable "workload_compartments" {
  description = "Child compartments created under the operating entity root compartment."
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

variable "admin_group_name" {
  description = "Optional existing-style name override for the operating entity admin group."
  type        = string
  default     = null
}

variable "auditor_group_name" {
  description = "Optional existing-style name override for the operating entity auditor group."
  type        = string
  default     = null
}

variable "policy_compartment_ocid" {
  description = "Compartment OCID where delegated operating entity policies are attached. Defaults to parent_compartment_ocid."
  type        = string
  default     = null
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
