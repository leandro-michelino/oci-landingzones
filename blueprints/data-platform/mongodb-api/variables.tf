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
  description = "Short organization prefix used in OCI resource names."
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
  description = "Compartment OCID where the Autonomous Database is created. Defaults to tenancy_ocid for validation-only tests."
  type        = string
  default     = null
}

variable "policy_compartment_ocid" {
  description = "Compartment OCID where optional IAM policies are created. Defaults to tenancy_ocid."
  type        = string
  default     = null
}

variable "defined_tags" {
  description = "Defined tags applied to created resources."
  type        = map(string)
  default     = {}
}

variable "freeform_tags" {
  description = "Freeform tags applied to created resources."
  type        = map(string)
  default     = {}
}

variable "enable_mongodb_api_database" {
  description = "Create the Autonomous Database with MongoDB API enabled."
  type        = bool
  default     = false
}

variable "create_private_network" {
  description = "Create a small private VCN, subnet, and NSG for the MongoDB API private endpoint."
  type        = bool
  default     = false
}

variable "vcn_cidr_block" {
  description = "CIDR block for the optional private VCN."
  type        = string
  default     = "10.80.0.0/16"
}

variable "subnet_cidr_block" {
  description = "CIDR block for the optional private endpoint subnet."
  type        = string
  default     = "10.80.10.0/24"
}

variable "vcn_display_name" {
  description = "Optional display name override for the private VCN."
  type        = string
  default     = null
}

variable "subnet_display_name" {
  description = "Optional display name override for the private endpoint subnet."
  type        = string
  default     = null
}

variable "nsg_display_name" {
  description = "Optional display name override for the MongoDB API NSG."
  type        = string
  default     = null
}

variable "vcn_dns_label" {
  description = "DNS label for the optional private VCN."
  type        = string
  default     = "mongovcn"
}

variable "subnet_dns_label" {
  description = "DNS label for the optional private endpoint subnet."
  type        = string
  default     = "mongosn"
}

variable "allowed_client_cidrs" {
  description = "CIDR blocks allowed to reach the MongoDB API private endpoint NSG."
  type        = list(string)
  default     = ["10.80.0.0/16"]
}

variable "mongodb_api_port" {
  description = "TCP port allowed to the MongoDB API private endpoint."
  type        = number
  default     = 27017
}

variable "db_name" {
  description = "Autonomous Database DB name. Use only letters and numbers."
  type        = string
  default     = "LZMONGO"

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9]{1,13}$", var.db_name))
    error_message = "db_name must start with a letter, contain only letters and numbers, and be 2 to 14 characters."
  }
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
  description = "Autonomous Database workload type. AJD is the default JSON/document workload for MongoDB API."
  type        = string
  default     = "AJD"

  validation {
    condition     = contains(["AJD", "OLTP"], var.db_workload)
    error_message = "db_workload must be AJD or OLTP."
  }
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

variable "is_auto_scaling_for_storage_enabled" {
  description = "Enable Autonomous Database storage auto-scaling."
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

  validation {
    condition     = contains(["LICENSE_INCLUDED", "BRING_YOUR_OWN_LICENSE"], var.license_model)
    error_message = "license_model must be LICENSE_INCLUDED or BRING_YOUR_OWN_LICENSE."
  }
}

variable "subnet_id" {
  description = "Private endpoint subnet OCID. Set this for private-only MongoDB API access."
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

variable "whitelisted_ips" {
  description = "Optional public endpoint allow-list CIDRs. Prefer subnet_id and NSGs for private deployments."
  type        = set(string)
  default     = []
}

variable "enable_public_access_control" {
  description = "Set true to configure public endpoint access control with whitelisted_ips. Leave false for Autonomous AI Database private endpoint deployments."
  type        = bool
  default     = false
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

variable "mongodb_api_tool_name" {
  description = "Autonomous Database tool name used to enable the MongoDB API."
  type        = string
  default     = "MONGODB_API"
}

variable "enable_mongodb_api" {
  description = "Enable the MongoDB API database tool."
  type        = bool
  default     = true
}

variable "mongodb_api_compute_count" {
  description = "Optional compute count for the MongoDB API tool."
  type        = number
  default     = null
}

variable "mongodb_api_max_idle_time_in_minutes" {
  description = "Optional max idle time for the MongoDB API tool."
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

variable "policy_statements" {
  description = "Optional IAM policy statements for app, DBA, or operator access."
  type        = list(string)
  default     = []
}
