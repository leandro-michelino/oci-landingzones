variable "tenancy_ocid" {
  description = "OCI tenancy OCID."
  type        = string
}

variable "region" {
  description = "Primary OCI region name."
  type        = string
}

variable "standby_region" {
  description = "Standby OCI region name."
  type        = string
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
  description = "Short primary OCI region key used in resource names."
  type        = string
}

variable "standby_region_key" {
  description = "Short standby OCI region key used in resource names."
  type        = string
}
