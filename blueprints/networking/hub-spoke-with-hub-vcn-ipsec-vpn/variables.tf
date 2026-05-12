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

variable "enable_ipsec" {
  description = "Create the IPSec VPN resources. Keep false until real CPE details are approved."
  type        = bool
  default     = false
}

variable "vpn_label" {
  description = "Short semantic label for the IPSec VPN."
  type        = string
  default     = "onprem"
}

variable "cpe_ip_address" {
  description = "Customer-premises equipment IP address."
  type        = string
  default     = null
}

variable "cpe_is_private" {
  description = "Whether the CPE IP address is private."
  type        = bool
  default     = false
}

variable "on_premises_cidr_blocks" {
  description = "On-premises CIDR blocks routed over the IPSec VPN."
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
