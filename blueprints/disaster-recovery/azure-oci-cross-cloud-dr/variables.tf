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

variable "compartment_ocid" {
  description = "Compartment OCID where OCI DR resources are created. Defaults to tenancy_ocid for validation-only tests."
  type        = string
  default     = null
}

variable "oci_is_primary" {
  description = "Set to true. This variant keeps OCI as the primary application target."
  type        = bool
  default     = true

  validation {
    condition     = var.oci_is_primary == true
    error_message = "oci_is_primary must be true for this blueprint variant."
  }
}

variable "connectivity_mode" {
  description = "Cross-cloud connectivity mode between OCI and Azure for DR data/control lanes."
  type        = string
  default     = "interconnect"

  validation {
    condition     = contains(["interconnect", "without-interconnect"], var.connectivity_mode)
    error_message = "connectivity_mode must be interconnect or without-interconnect."
  }
}

variable "fastconnect_virtual_circuit_id" {
  description = "OCI FastConnect virtual circuit OCID used when connectivity_mode is interconnect."
  type        = string
  default     = null
}

variable "expressroute_circuit_id" {
  description = "Azure ExpressRoute circuit resource ID used when connectivity_mode is interconnect."
  type        = string
  default     = null
}

variable "enable_dr_evidence_bucket" {
  description = "Create an Object Storage bucket for failover drill evidence and incident artifacts."
  type        = bool
  default     = true
}

variable "dr_evidence_bucket_name" {
  description = "Optional name for the DR evidence bucket."
  type        = string
  default     = null
}

variable "enable_dr_alert_topic" {
  description = "Create an OCI Notifications topic for DR drill and failover alerts."
  type        = bool
  default     = true
}

variable "dr_alert_topic_name" {
  description = "Optional name for the DR alert Notifications topic."
  type        = string
  default     = null
}

variable "dr_alert_topic_description" {
  description = "Optional description for the DR alert Notifications topic."
  type        = string
  default     = "Cross-cloud DR failover and drill alert topic"
}

variable "enable_dns_failover_contract" {
  description = "Publish DNS failover contract metadata for primary-to-standby cutover."
  type        = bool
  default     = true
}

variable "enable_runbook_contract" {
  description = "Publish DR failover/failback runbook contract metadata."
  type        = bool
  default     = true
}

variable "app_fqdn" {
  description = "Application FQDN used for DNS failover between OCI primary and Azure standby."
  type        = string
  default     = "app.example.com"
}

variable "oci_primary_endpoint" {
  description = "Primary OCI application endpoint used by DNS failover runbooks."
  type        = string
  default     = null
}

variable "azure_standby_endpoint" {
  description = "Azure standby application endpoint used by DNS failover runbooks."
  type        = string
  default     = null
}

variable "oci_primary_health_path" {
  description = "Health-check path used for OCI primary endpoint validation."
  type        = string
  default     = "/healthz"
}

variable "azure_standby_health_path" {
  description = "Health-check path used for Azure standby endpoint validation."
  type        = string
  default     = "/healthz"
}

variable "dns_ttl_seconds" {
  description = "DNS TTL used in failover runbooks for cutover timing assumptions."
  type        = number
  default     = 30
}

variable "dr_drill_frequency" {
  description = "Expected DR drill cadence for runbook governance."
  type        = string
  default     = "quarterly"
}

variable "target_rto_minutes" {
  description = "Target recovery time objective in minutes."
  type        = number
  default     = 30
}

variable "target_rpo_minutes" {
  description = "Target recovery point objective in minutes."
  type        = number
  default     = 15
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
