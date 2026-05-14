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

variable "create_db_system" {
  description = "Create the MySQL DB System."
  type        = bool
  default     = false
}
variable "db_system_id" {
  description = "Existing MySQL DB System OCID when create_db_system is false."
  type        = string
  default     = null
}
variable "db_system_display_name" {
  description = "Optional MySQL DB System display name override."
  type        = string
  default     = null
}
variable "db_system_description" {
  description = "MySQL DB System description."
  type        = string
  default     = "MySQL HeatWave DB System managed by Terraform."
}
variable "availability_domain" {
  description = "Availability domain for the MySQL DB System."
  type        = string
  default     = null
}
variable "fault_domain" {
  description = "Optional fault domain."
  type        = string
  default     = null
}
variable "db_shape_name" {
  description = "MySQL DB System shape name."
  type        = string
  default     = "MySQL.VM.Standard.E4.1.8GB"
}
variable "subnet_id" {
  description = "Private subnet OCID for the MySQL endpoint."
  type        = string
  default     = null
}
variable "nsg_ids" {
  description = "Network security group OCIDs for the MySQL endpoint."
  type        = set(string)
  default     = []
}
variable "hostname_label" {
  description = "Optional hostname label for the MySQL endpoint."
  type        = string
  default     = null
}
variable "mysql_version" {
  description = "MySQL version."
  type        = string
  default     = null
}
variable "admin_username" {
  description = "MySQL administrator username."
  type        = string
  default     = null
}
variable "admin_password" {
  description = "MySQL administrator password. Supply through local ignored tfvars or a secure pipeline secret."
  type        = string
  default     = null
  sensitive   = true
}
variable "data_storage_size_in_gb" {
  description = "Initial MySQL storage size in GB."
  type        = number
  default     = 50
}
variable "is_highly_available" {
  description = "Enable a highly available MySQL DB System."
  type        = bool
  default     = false
}
variable "configuration_id" {
  description = "Optional MySQL configuration OCID."
  type        = string
  default     = null
}
variable "backup_enabled" {
  description = "Enable automatic MySQL backups."
  type        = bool
  default     = true
}
variable "backup_retention_in_days" {
  description = "Backup retention in days."
  type        = number
  default     = 7
}
variable "backup_window_start_time" {
  description = "Backup window start time, for example 02:00."
  type        = string
  default     = null
}

variable "create_heatwave_cluster" {
  description = "Create a HeatWave cluster attached to the DB System."
  type        = bool
  default     = false
}
variable "heatwave_cluster_id" {
  description = "Existing HeatWave cluster identifier when create_heatwave_cluster is false."
  type        = string
  default     = null
}
variable "heatwave_shape_name" {
  description = "HeatWave cluster shape name."
  type        = string
  default     = "HeatWave.512GB"
}
variable "heatwave_cluster_size" {
  description = "HeatWave cluster node count."
  type        = number
  default     = 1
}
variable "enable_heatwave_lakehouse" {
  description = "Enable HeatWave Lakehouse on the HeatWave cluster."
  type        = bool
  default     = false
}

variable "create_lakehouse_bucket" {
  description = "Create an Object Storage bucket for HeatWave Lakehouse tables or exports."
  type        = bool
  default     = false
}
variable "lakehouse_bucket_name" {
  description = "Optional lakehouse bucket name override."
  type        = string
  default     = null
}
variable "lakehouse_bucket_storage_tier" {
  description = "Lakehouse bucket storage tier."
  type        = string
  default     = "Standard"
}
variable "lakehouse_bucket_versioning" {
  description = "Lakehouse bucket versioning setting."
  type        = string
  default     = "Enabled"
}
variable "kms_key_id" {
  description = "Optional KMS key OCID for bucket and DB encryption."
  type        = string
  default     = null
}
variable "policy_compartment_ocid" {
  description = "Compartment OCID where the optional IAM policy is created. Defaults to tenancy_ocid."
  type        = string
  default     = null
}
variable "policy_statements" {
  description = "Optional IAM policy statements for DBAs, app users, analytics operators, and auditors."
  type        = list(string)
  default     = []
}
