# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
variable "tenancy_ocid" {
  description = "OCI tenancy OCID."
  type        = string
}

variable "compartment_ocid" {
  description = "Parent compartment OCID for resources managed by this module."
  type        = string
}

variable "region" {
  description = "OCI region name."
  type        = string
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

variable "enable_ipsec" {
  description = "Create the CPE and IPSec connection."
  type        = bool
  default     = false
}

variable "vpn_label" {
  description = "Short semantic label for the VPN connection."
  type        = string
  default     = "onprem"
}

variable "drg_id" {
  description = "DRG OCID used by the IPSec connection."
  type        = string
  default     = null
}

variable "cpe_ip_address" {
  description = "Public or private IP address of the customer-premises equipment."
  type        = string
  default     = null
}

variable "cpe_is_private" {
  description = "Whether the CPE IP address is private."
  type        = bool
  default     = false
}

variable "cpe_display_name" {
  description = "Optional CPE display name override."
  type        = string
  default     = null
}

variable "ipsec_display_name" {
  description = "Optional IPSec display name override."
  type        = string
  default     = null
}

variable "static_routes" {
  description = "On-premises CIDR routes advertised over the IPSec connection."
  type        = list(string)
  default     = []
}

variable "cis_level" {
  description = "CIS OCI Benchmark profile for the landing zone. Use level1 for baseline controls or level2 for stricter controls."
  type        = string
  default     = null

  validation {
    condition     = var.cis_level == null ? true : contains(["level1", "level2"], lower(var.cis_level))
    error_message = "cis_level must be either level1 or level2."
  }
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
