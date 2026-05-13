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
variable "enable_log_analytics_namespace" {
  description = "Create or onboard the Log Analytics namespace."
  type        = bool
  default     = false
}
variable "log_analytics_namespace" {
  description = "Log Analytics namespace name."
  type        = string
  default     = "default"
}
variable "log_analytics_is_onboarded" {
  description = "Whether the namespace is onboarded."
  type        = bool
  default     = true
}
variable "enable_log_group" {
  description = "Create a Log Analytics log group."
  type        = bool
  default     = false
}
variable "log_group_name" {
  description = "Optional Log Analytics log group name override."
  type        = string
  default     = null
}
variable "log_group_description" {
  description = "Log group description."
  type        = string
  default     = "Landing zone observability log group."
}
variable "enable_apm_domain" {
  description = "Create an APM domain."
  type        = bool
  default     = false
}
variable "apm_domain_name" {
  description = "Optional APM domain name override."
  type        = string
  default     = null
}
variable "apm_domain_description" {
  description = "APM domain description."
  type        = string
  default     = "Landing zone APM domain."
}
variable "apm_is_free_tier" {
  description = "Create an APM free-tier domain when supported."
  type        = bool
  default     = true
}
variable "enable_opsi_private_endpoint" {
  description = "Create an Operations Insights private endpoint."
  type        = bool
  default     = false
}
variable "opsi_private_endpoint_name" {
  description = "Optional Operations Insights private endpoint name override."
  type        = string
  default     = null
}
variable "opsi_private_endpoint_description" {
  description = "Operations Insights private endpoint description."
  type        = string
  default     = "Landing zone Operations Insights private endpoint."
}
variable "vcn_id" {
  description = "VCN OCID for Operations Insights private endpoint."
  type        = string
  default     = null
}
variable "subnet_id" {
  description = "Subnet OCID for Operations Insights private endpoint."
  type        = string
  default     = null
}
variable "nsg_ids" {
  description = "NSG OCIDs for Operations Insights private endpoint."
  type        = set(string)
  default     = []
}
variable "opsi_is_used_for_rac_dbs" {
  description = "Whether this Operations Insights endpoint is used for RAC databases."
  type        = bool
  default     = false
}
