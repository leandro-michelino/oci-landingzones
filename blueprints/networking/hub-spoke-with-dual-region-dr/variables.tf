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

variable "secondary_region" {
  description = "Secondary OCI region for DR."
  type        = string
  default     = "eu-amsterdam-1"
}

variable "secondary_region_key" {
  description = "Short OCI region key for the secondary DR region."
  type        = string
  default     = "ams"
}

variable "compartment_ocid" {
  description = "Primary region networking compartment OCID. Defaults to tenancy_ocid for simple tests."
  type        = string
  default     = null
}

variable "secondary_compartment_ocid" {
  description = "Secondary region networking compartment OCID. Defaults to compartment_ocid."
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
