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
variable "enable_private_endpoint" {
  description = "Create the OCI Generative AI private endpoint."
  type        = bool
  default     = false
}
variable "endpoint_display_name" {
  description = "Optional private endpoint display name override."
  type        = string
  default     = null
}
variable "description" {
  description = "Private endpoint description."
  type        = string
  default     = "Private OCI Generative AI endpoint managed by Terraform."
}
variable "dns_prefix" {
  description = "DNS prefix for the private endpoint."
  type        = string
  default     = "genai"
}
variable "subnet_id" {
  description = "Subnet OCID for the private endpoint."
  type        = string
  default     = null
}
variable "nsg_ids" {
  description = "NSG OCIDs for the private endpoint."
  type        = set(string)
  default     = []
}
variable "create_archive_bucket" {
  description = "Create a private Object Storage archive bucket."
  type        = bool
  default     = false
}
variable "archive_bucket_name" {
  description = "Optional archive bucket name override."
  type        = string
  default     = null
}
variable "archive_storage_tier" {
  description = "Archive bucket storage tier."
  type        = string
  default     = "Standard"
}
variable "archive_versioning" {
  description = "Archive bucket versioning setting."
  type        = string
  default     = "Enabled"
}
variable "archive_object_events_enabled" {
  description = "Emit object events for archive bucket writes."
  type        = bool
  default     = true
}
variable "kms_key_id" {
  description = "Optional KMS key OCID for archive bucket encryption."
  type        = string
  default     = null
}
variable "policy_compartment_ocid" {
  description = "Compartment OCID where the IAM policy is created. Defaults to tenancy_ocid."
  type        = string
  default     = null
}
variable "policy_statements" {
  description = "IAM policy statements for GenAI users, groups, or dynamic groups."
  type        = list(string)
  default     = []
}
