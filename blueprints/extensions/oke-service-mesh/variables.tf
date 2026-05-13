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
variable "enable_service_mesh_addon" {
  description = "Enable the OKE service mesh add-on."
  type        = bool
  default     = false
}
variable "cluster_id" {
  description = "Existing OKE cluster OCID."
  type        = string
  default     = null
}
variable "addon_name" {
  description = "Container Engine add-on name for service mesh."
  type        = string
  default     = "ServiceMesh"
}
variable "addon_version" {
  description = "Optional add-on version."
  type        = string
  default     = null
}
variable "override_existing" {
  description = "Override an existing add-on installation."
  type        = bool
  default     = false
}
variable "remove_addon_resources_on_delete" {
  description = "Remove add-on resources when Terraform destroys the add-on."
  type        = bool
  default     = false
}
variable "addon_configurations" {
  description = "OKE add-on key/value configuration entries."
  type        = list(object({ key = string, value = string }))
  default     = []
}
variable "enable_apm_domain" {
  description = "Create an APM domain for mesh tracing."
  type        = bool
  default     = false
}
variable "apm_domain_name" {
  description = "Optional APM domain name override."
  type        = string
  default     = null
}
variable "apm_domain_description" {
  description = "APM tracing domain description."
  type        = string
  default     = "OKE service mesh tracing domain."
}
variable "apm_is_free_tier" {
  description = "Create an APM free-tier domain when supported."
  type        = bool
  default     = true
}
