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

variable "enable_logging" {
  description = "Create OCI Logging log groups, service logs, and saved searches."
  type        = bool
  default     = true
}

variable "log_groups" {
  description = "Additional or overriding log groups keyed by logical name."
  type = map(object({
    display_name = optional(string)
    description  = optional(string)
  }))
  default = {}
}

variable "service_logs" {
  description = "OCI service logs keyed by logical name. Use for Object Storage, Load Balancer, API Gateway, and other OCI service logs when source resource OCIDs are known."
  type = map(object({
    log_group_key      = optional(string, "service")
    display_name       = optional(string)
    service            = string
    category           = string
    resource_id        = string
    source_type        = optional(string, "OCISERVICE")
    compartment_ocid   = optional(string)
    retention_duration = optional(number, 30)
    is_enabled         = optional(bool, true)
    parameters         = optional(map(string), {})
  }))
  default = {}
}

variable "vcn_flow_logs" {
  description = "Convenience VCN flow log definitions keyed by logical name. Resource IDs can be VCN, subnet, or other flow-log-supported network resource OCIDs."
  type = map(object({
    log_group_key      = optional(string, "network")
    display_name       = optional(string)
    resource_id        = string
    compartment_ocid   = optional(string)
    category           = optional(string, "all")
    retention_duration = optional(number, 30)
    is_enabled         = optional(bool, true)
    parameters         = optional(map(string), {})
  }))
  default = {}
}

variable "saved_searches" {
  description = "Logging saved searches keyed by logical name."
  type = map(object({
    name             = optional(string)
    description      = optional(string)
    query            = string
    compartment_ocid = optional(string)
  }))
  default = {}
}

variable "enable_audit_retention" {
  description = "Configure tenancy audit retention. This is tenancy-wide and should be enabled deliberately."
  type        = bool
  default     = false
}

variable "audit_retention_period_days" {
  description = "Tenancy audit retention in days when enable_audit_retention is true."
  type        = number
  default     = 365

  validation {
    condition     = var.audit_retention_period_days >= 90 && var.audit_retention_period_days <= 365
    error_message = "audit_retention_period_days must be between 90 and 365."
  }
}
