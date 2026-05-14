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
variable "enable_db_system" {
  description = "Create the PostgreSQL DB system."
  type        = bool
  default     = false
}
variable "db_system_display_name" {
  description = "Optional PostgreSQL DB system display name override."
  type        = string
  default     = null
}
variable "description" {
  description = "PostgreSQL DB system description."
  type        = string
  default     = "Landing zone PostgreSQL DB system."
}
variable "db_version" {
  description = "PostgreSQL database version."
  type        = string
  default     = "14"
}
variable "shape" {
  description = "PostgreSQL DB system shape."
  type        = string
  default     = "PostgreSQL.VM.Standard.E4.Flex"
}
variable "system_type" {
  description = "PostgreSQL DB system type."
  type        = string
  default     = "OCI_OPTIMIZED_STORAGE"
}
variable "config_id" {
  description = "Optional PostgreSQL configuration OCID."
  type        = string
  default     = null
}
variable "instance_count" {
  description = "Number of PostgreSQL DB system instances."
  type        = number
  default     = 1
}
variable "instance_ocpu_count" {
  description = "OCPU count per PostgreSQL instance."
  type        = number
  default     = 1
}
variable "instance_memory_size_in_gbs" {
  description = "Memory in GB per PostgreSQL instance."
  type        = number
  default     = 16
}
variable "admin_username" {
  description = "PostgreSQL admin username."
  type        = string
  default     = "postgres"
}
variable "admin_password" {
  description = "PostgreSQL admin password supplied from a secure variable source when using plain text password mode."
  type        = string
  default     = null
  sensitive   = true
}
variable "admin_password_type" {
  description = "PostgreSQL password type expected by the OCI API."
  type        = string
  default     = "PLAIN_TEXT"
}
variable "admin_password_secret_id" {
  description = "Optional Vault secret OCID for the admin password."
  type        = string
  default     = null
}
variable "admin_password_secret_version" {
  description = "Optional Vault secret version for the admin password."
  type        = string
  default     = null
}
variable "subnet_id" {
  description = "Private subnet OCID for PostgreSQL."
  type        = string
  default     = null
}
variable "nsg_ids" {
  description = "NSG OCIDs allowed to reach PostgreSQL."
  type        = set(string)
  default     = []
}
variable "primary_db_endpoint_private_ip" {
  description = "Optional private IP for the primary PostgreSQL endpoint."
  type        = string
  default     = null
}
variable "is_reader_endpoint_enabled" {
  description = "Enable a reader endpoint when supported."
  type        = bool
  default     = false
}
variable "storage_system_type" {
  description = "Storage details system type."
  type        = string
  default     = "OCI_OPTIMIZED_STORAGE"
}
variable "is_regionally_durable" {
  description = "Use regionally durable storage."
  type        = bool
  default     = true
}
variable "availability_domain" {
  description = "Optional availability domain for non-regionally durable storage."
  type        = string
  default     = null
}
variable "iops" {
  description = "Optional storage IOPS."
  type        = string
  default     = null
}
variable "instances_details" {
  description = "Optional per-instance display names, descriptions, and private IPs."
  type = list(object({
    display_name = optional(string)
    description  = optional(string)
    private_ip   = optional(string)
  }))
  default = []
}
variable "enable_management_policy" {
  description = "Configure PostgreSQL maintenance and backup policy."
  type        = bool
  default     = true
}
variable "maintenance_window_start" {
  description = "Optional maintenance window start value."
  type        = string
  default     = null
}
variable "backup_policy" {
  description = "Optional PostgreSQL backup policy."
  type = object({
    backup_start      = optional(string)
    days_of_the_month = optional(list(number), [])
    days_of_the_week  = optional(list(string), [])
    kind              = optional(string)
    retention_days    = optional(number)
    copy_policy = optional(object({
      compartment_id   = string
      regions          = list(string)
      retention_period = optional(number)
    }))
  })
  default = null
}
variable "db_source" {
  description = "Optional source settings for restore or clone workflows."
  type = object({
    source_type                        = string
    backup_id                          = optional(string)
    is_having_restore_config_overrides = optional(bool)
  })
  default = null
}
variable "policy_compartment_ocid" {
  description = "Compartment OCID where the optional IAM policy is created. Defaults to tenancy_ocid."
  type        = string
  default     = null
}
variable "policy_statements" {
  description = "Optional IAM policy statements for PostgreSQL operators, DBAs, or app groups."
  type        = list(string)
  default     = []
}
