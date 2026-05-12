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
  description = "Compartment OCID where networking resources are deployed. Defaults to tenancy_ocid for simple tests."
  type        = string
  default     = null
}

variable "enable_fastconnect" {
  description = "Create FastConnect for cloud exchange or partner connectivity."
  type        = bool
  default     = false
}

variable "enable_ipsec" {
  description = "Create IPSec as a backup or primary multicloud tunnel."
  type        = bool
  default     = false
}

variable "customer_bgp_asn" {
  description = "Customer BGP ASN for FastConnect."
  type        = number
  default     = null
}

variable "provider_service_id" {
  description = "Provider service OCID for partner FastConnect circuits."
  type        = string
  default     = null
}

variable "provider_service_key_name" {
  description = "Provider service key/name supplied by the FastConnect partner."
  type        = string
  default     = null
}

variable "cpe_ip_address" {
  description = "Remote cloud VPN gateway public or private IP address."
  type        = string
  default     = null
}

variable "remote_cloud_cidr_blocks" {
  description = "Remote cloud CIDR blocks routed over IPSec."
  type        = list(string)
  default     = []
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
