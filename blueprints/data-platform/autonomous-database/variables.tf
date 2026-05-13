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
  description = "Compartment OCID where resources are created. Defaults to tenancy_ocid for validation-only tests."
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
variable "enable_autonomous_database" {
  description = "Create the Autonomous Database resources."
  type        = bool
  default     = false
}
variable "db_name" {
  description = "Autonomous Database DB name."
  type        = string
  default     = "LZADB"
}
variable "database_display_name" {
  description = "Optional Autonomous Database display name override."
  type        = string
  default     = null
}
variable "admin_password" {
  description = "Autonomous Database admin password supplied from a secure variable source."
  type        = string
  default     = null
  sensitive   = true
}
variable "db_workload" {
  description = "Autonomous Database workload type: OLTP or DW."
  type        = string
  default     = "OLTP"
}
variable "compute_model" {
  description = "Autonomous Database compute model."
  type        = string
  default     = "ECPU"
}
variable "compute_count" {
  description = "Autonomous Database compute count."
  type        = number
  default     = 2
}
variable "data_storage_size_in_tbs" {
  description = "Database storage in TB."
  type        = number
  default     = 1
}
variable "is_auto_scaling_enabled" {
  description = "Enable Autonomous Database compute auto-scaling."
  type        = bool
  default     = true
}
variable "is_mtls_connection_required" {
  description = "Require mutual TLS for database connections."
  type        = bool
  default     = true
}
variable "is_free_tier" {
  description = "Create as Always Free when supported."
  type        = bool
  default     = false
}
variable "license_model" {
  description = "Autonomous Database license model."
  type        = string
  default     = "LICENSE_INCLUDED"
}
variable "subnet_id" {
  description = "Private endpoint subnet OCID."
  type        = string
  default     = null
}
variable "nsg_ids" {
  description = "NSG OCIDs for the private endpoint."
  type        = set(string)
  default     = []
}
variable "private_endpoint_label" {
  description = "Private endpoint DNS label."
  type        = string
  default     = null
}
variable "kms_key_id" {
  description = "Optional KMS key OCID."
  type        = string
  default     = null
}
variable "backup_retention_period_in_days" {
  description = "Automatic backup retention in days."
  type        = number
  default     = null
}
variable "create_manual_backup" {
  description = "Create an initial manual backup."
  type        = bool
  default     = false
}
variable "manual_backup_is_long_term" {
  description = "Mark the manual backup as long term."
  type        = bool
  default     = false
}
variable "manual_backup_retention_period_in_days" {
  description = "Manual backup retention in days."
  type        = number
  default     = null
}
