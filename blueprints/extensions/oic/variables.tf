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
variable "enable_integration_instance" {
  description = "Create the OIC instance."
  type        = bool
  default     = false
}
variable "integration_display_name" {
  description = "Optional OIC display name override."
  type        = string
  default     = null
}
variable "integration_instance_type" {
  description = "OIC instance type."
  type        = string
  default     = "STANDARD"
}
variable "is_byol" {
  description = "Use BYOL licensing."
  type        = bool
  default     = false
}
variable "message_packs" {
  description = "OIC message pack count."
  type        = number
  default     = 1
}
variable "consumption_model" {
  description = "Optional OIC consumption model."
  type        = string
  default     = null
}
variable "shape" {
  description = "Optional OIC shape."
  type        = string
  default     = null
}
variable "is_file_server_enabled" {
  description = "Enable OIC File Server."
  type        = bool
  default     = false
}
variable "is_visual_builder_enabled" {
  description = "Enable Visual Builder."
  type        = bool
  default     = false
}
variable "is_disaster_recovery_enabled" {
  description = "Enable OIC disaster recovery."
  type        = bool
  default     = false
}
variable "data_retention_period" {
  description = "Optional data retention period."
  type        = string
  default     = null
}
variable "domain_id" {
  description = "Optional identity domain OCID."
  type        = string
  default     = null
}
variable "idcs_access_token" {
  description = "Optional IDCS access token from a secure variable source."
  type        = string
  default     = null
  sensitive   = true
}
variable "existing_integration_instance_id" {
  description = "Existing OIC instance OCID used for outbound connection only."
  type        = string
  default     = null
}
variable "enable_private_outbound_connection" {
  description = "Create a private outbound connection."
  type        = bool
  default     = false
}
variable "outbound_subnet_id" {
  description = "Subnet OCID for private outbound connection."
  type        = string
  default     = null
}
variable "outbound_nsg_ids" {
  description = "NSG OCIDs for private outbound connection."
  type        = set(string)
  default     = []
}
