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
variable "enable_analytics_instance" {
  description = "Create the OAC instance."
  type        = bool
  default     = false
}
variable "analytics_instance_name" {
  description = "Optional OAC instance name override."
  type        = string
  default     = null
}
variable "description" {
  description = "OAC instance description."
  type        = string
  default     = "Landing zone Oracle Analytics Cloud instance."
}
variable "feature_set" {
  description = "OAC feature set."
  type        = string
  default     = "ENTERPRISE_ANALYTICS"
}
variable "license_type" {
  description = "OAC license type."
  type        = string
  default     = "LICENSE_INCLUDED"
}
variable "capacity_type" {
  description = "OAC capacity type."
  type        = string
  default     = "OLPU_COUNT"
}
variable "capacity_value" {
  description = "OAC capacity value."
  type        = number
  default     = 1
}
variable "email_notification" {
  description = "Optional notification email."
  type        = string
  default     = null
}
variable "kms_key_id" {
  description = "Optional KMS key OCID."
  type        = string
  default     = null
}
variable "domain_id" {
  description = "Optional identity domain OCID."
  type        = string
  default     = null
}
variable "existing_analytics_instance_id" {
  description = "Existing OAC instance OCID for private access channel only."
  type        = string
  default     = null
}
variable "enable_private_access_channel" {
  description = "Create a private access channel."
  type        = bool
  default     = false
}
variable "private_access_channel_name" {
  description = "Optional private access channel name override."
  type        = string
  default     = null
}
variable "vcn_id" {
  description = "VCN OCID for private access channel."
  type        = string
  default     = null
}
variable "subnet_id" {
  description = "Subnet OCID for private access channel."
  type        = string
  default     = null
}
variable "network_security_group_ids" {
  description = "NSG OCIDs for private access channel."
  type        = set(string)
  default     = []
}
variable "private_source_dns_zones" {
  description = "Private DNS zones reachable from the private access channel."
  type        = list(object({ dns_zone = string, description = optional(string) }))
  default     = []
}
