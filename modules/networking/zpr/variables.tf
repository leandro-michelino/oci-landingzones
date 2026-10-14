variable "tenancy_ocid" {
  description = "OCI tenancy OCID."
  type        = string
}

variable "compartment_ocid" {
  description = "Workload compartment context; ZPR configuration and policies are tenancy-root resources."
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

variable "enable_zpr_configuration" {
  description = "Onboard or manage ZPR at tenancy root. Use the tenancy home-region provider for configuration."
  type        = bool
  default     = false
}

variable "zpr_status" {
  description = "Requested ZPR status when enable_zpr_configuration is true."
  type        = string
  default     = "ENABLED"
}

variable "enable_zpr_policies" {
  description = "Create ZPR policies."
  type        = bool
  default     = false
}

variable "zpr_policies" {
  description = "ZPR policies keyed by logical name."
  type = map(object({
    name        = string
    description = string
    statements  = list(string)
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
