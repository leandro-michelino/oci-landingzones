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
  description = "Parent compartment OCID for the zero-trust landing zone root compartment. Defaults to tenancy_ocid when omitted."
  type        = string
  default     = null
}

variable "network_compartment_ocid" {
  description = "Optional compartment OCID for zero-trust network resources. Defaults to the network compartment created by core."
  type        = string
  default     = null
}

variable "enable_delete" {
  description = "Allow Terraform to delete compartments during destroy. Review carefully for production."
  type        = bool
  default     = true
}

variable "enable_tagging" {
  description = "Create the landing zone tag namespace, tag definitions, and tag defaults."
  type        = bool
  default     = true
}

variable "enable_tag_defaults" {
  description = "Create tag defaults for zero-trust landing zone compartments."
  type        = bool
  default     = true
}

variable "vault_enabled" {
  description = "Create OCI Vault resources through the core blueprint."
  type        = bool
  default     = true
}

variable "enable_default_vault_key" {
  description = "Create a default KMS key when the default vault is created."
  type        = bool
  default     = true
}

variable "security_zones_enabled" {
  description = "Create OCI Security Zones through the core blueprint."
  type        = bool
  default     = false
}

variable "default_security_zone_recipe_id" {
  description = "Security Zone recipe OCID used by the default Security Zone."
  type        = string
  default     = null
}

variable "vss_enabled" {
  description = "Create Vulnerability Scanning Service resources through the core blueprint."
  type        = bool
  default     = true
}

variable "enable_default_host_scan" {
  description = "Create the default VSS host scan recipe and target."
  type        = bool
  default     = true
}

variable "enable_events" {
  description = "Create OCI Events and Notifications resources through the core blueprint."
  type        = bool
  default     = true
}

variable "monitoring_enabled" {
  description = "Create OCI Monitoring resources through the core blueprint."
  type        = bool
  default     = false
}

variable "enable_zpr_configuration" {
  description = "Enable Zero Trust Packet Routing configuration."
  type        = bool
  default     = false
}

variable "enable_zpr_policies" {
  description = "Create ZPR policy statements for the zero-trust network."
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
  default = {
    zero_trust_tiers = {
      name        = "zero-trust-tier-guardrails"
      description = "Starter ZPR policy for zero-trust tier isolation."
      statements  = []
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
