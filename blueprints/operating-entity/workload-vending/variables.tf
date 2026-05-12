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
  description = "Parent operating entity or workload compartment OCID. Defaults to tenancy_ocid for simple tests."
  type        = string
  default     = null
}

variable "workload_code" {
  description = "Short workload code used in names."
  type        = string
  default     = "app"
}

variable "workload_name" {
  description = "Human-readable workload name."
  type        = string
  default     = null
}

variable "root_compartment_name" {
  description = "Optional workload root compartment display name."
  type        = string
  default     = null
}

variable "root_compartment_description" {
  description = "Description for the workload root compartment."
  type        = string
  default     = "Workload compartment package managed by Terraform."
}

variable "enable_delete" {
  description = "Allow Terraform to delete created workload compartments during destroy."
  type        = bool
  default     = true
}

variable "child_compartments" {
  description = "Child compartments created under the workload root."
  type = map(object({
    description   = string
    enable_delete = optional(bool)
  }))
  default = {
    app = {
      description = "Application compute and runtime resources."
    }
    data = {
      description = "Application data resources."
    }
    ops = {
      description = "Operational resources for the workload."
    }
  }
}

variable "admin_group_name" {
  description = "Optional workload admin group name override."
  type        = string
  default     = null
}

variable "operator_group_name" {
  description = "Optional workload operator group name override."
  type        = string
  default     = null
}

variable "auditor_group_name" {
  description = "Optional workload auditor group name override."
  type        = string
  default     = null
}

variable "policy_compartment_ocid" {
  description = "Compartment OCID where workload policies are attached. Defaults to parent_compartment_ocid."
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
