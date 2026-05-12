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
  description = "Optional OCI CLI config profile for local execution. Leave null to use the provider default profile."
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

variable "cis_level" {
  description = "Optional CIS OCI Benchmark profile selected by dedicated CIS wrapper blueprints."
  type        = string
  default     = null

  validation {
    condition     = var.cis_level == null ? true : contains(["level1", "level2"], lower(var.cis_level))
    error_message = "cis_level must be either level1 or level2."
  }
}

variable "parent_compartment_ocid" {
  description = "Parent compartment OCID for the landing zone root compartment. Defaults to tenancy_ocid when omitted."
  type        = string
  default     = null
}

variable "enable_delete" {
  description = "Allow Terraform to delete compartments during destroy. Keep true for ephemeral tests; review carefully for production."
  type        = bool
  default     = true
}

variable "tag_default_values" {
  description = "Optional overrides for default values in the landing zone tag namespace."
  type        = map(string)
  default     = {}
}

variable "tag_namespace_name" {
  description = "Optional tag namespace name override. Useful for ephemeral tests where tag namespace names must stay unique."
  type        = string
  default     = null
}

variable "enable_tagging" {
  description = "Create the landing zone tag namespace, tag definitions, and tag defaults. Disable for fast ephemeral tests."
  type        = bool
  default     = true
}

variable "enable_tag_defaults" {
  description = "Create tag defaults for the landing zone compartments. Disable for faster tests while keeping tag definitions."
  type        = bool
  default     = true
}

variable "required_tag_defaults" {
  description = "Tag names whose tag defaults should be marked required."
  type        = set(string)
  default     = []
}

variable "iam_groups" {
  description = "Additional or overriding IAM groups keyed by logical role."
  type = map(object({
    name        = optional(string)
    description = string
  }))
  default = {}
}

variable "enable_default_iam_groups" {
  description = "Create default landing zone IAM groups."
  type        = bool
  default     = true
}

variable "enable_default_dynamic_groups" {
  description = "Create default dynamic groups for platform automation and workload instances."
  type        = bool
  default     = true
}

variable "iam_dynamic_groups" {
  description = "Additional or overriding dynamic groups keyed by logical role."
  type = map(object({
    name          = optional(string)
    description   = string
    matching_rule = string
  }))
  default = {}
}

variable "enable_default_iam_policies" {
  description = "Create default least-privilege IAM policies for the core landing zone."
  type        = bool
  default     = true
}

variable "iam_policies" {
  description = "Additional or overriding IAM policies keyed by logical role."
  type = map(object({
    name           = optional(string)
    compartment_id = optional(string)
    description    = string
    statements     = list(string)
  }))
  default = {}
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
