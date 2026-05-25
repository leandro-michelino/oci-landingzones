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
  description = "Compartment OCID where OCI hybrid backbone resources are created. Defaults to tenancy_ocid for validation-only tests."
  type        = string
  default     = null
}

variable "oci_is_primary" {
  description = "Set to true. This pattern keeps OCI DRG as the primary hybrid backbone hub."
  type        = bool
  default     = true

  validation {
    condition     = var.oci_is_primary == true
    error_message = "oci_is_primary must be true for this blueprint variant."
  }
}

variable "enable_oci_backbone_network" {
  description = "Create OCI VCN, route table, security list, and subnet for the hybrid backbone."
  type        = bool
  default     = true
}

variable "existing_oci_backbone_vcn_id" {
  description = "Existing OCI VCN OCID to reuse instead of creating a new backbone VCN."
  type        = string
  default     = null

  validation {
    condition     = !(var.enable_oci_backbone_network && var.existing_oci_backbone_vcn_id != null)
    error_message = "Set either enable_oci_backbone_network=true (create VCN) or existing_oci_backbone_vcn_id (reuse VCN), not both."
  }
}

variable "oci_backbone_vcn_cidr" {
  description = "CIDR block for OCI backbone VCN when enable_oci_backbone_network is true."
  type        = string
  default     = "10.54.0.0/16"
}

variable "oci_backbone_subnet_cidr" {
  description = "CIDR block for OCI backbone subnet when enable_oci_backbone_network is true."
  type        = string
  default     = "10.54.10.0/24"
}

variable "oci_backbone_ingress_allowed_cidr" {
  description = "Source CIDR allowed to ingress OCI backbone subnet over HTTPS."
  type        = string
  default     = "10.0.0.0/8"
}

variable "existing_oci_primary_drg_id" {
  description = "Existing OCI DRG OCID to reuse instead of creating a new DRG."
  type        = string
  default     = null
}

variable "attach_oci_backbone_vcn_to_drg" {
  description = "Attach OCI backbone VCN to the effective DRG. Disable when reusing a VCN that is already attached."
  type        = bool
  default     = true
}

variable "connectivity_mode" {
  description = "Connectivity mode between OCI and AWS: without-interconnect (IPSec first) or interconnect."
  type        = string
  default     = "without-interconnect"

  validation {
    condition     = contains(["interconnect", "without-interconnect"], var.connectivity_mode)
    error_message = "connectivity_mode must be interconnect or without-interconnect."
  }
}

variable "fastconnect_virtual_circuit_id" {
  description = "OCI FastConnect virtual circuit OCID used when connectivity_mode is interconnect."
  type        = string
  default     = null
}

variable "direct_connect_connection_id" {
  description = "AWS Direct Connect connection ID used when connectivity_mode is interconnect."
  type        = string
  default     = null
}

variable "enable_site_to_site_vpn" {
  description = "Create OCI CPE and IPSec resources for site-to-site VPN path to AWS."
  type        = bool
  default     = true
}

variable "aws_cpe_public_ip" {
  description = "Public IP address of AWS VPN endpoint used for OCI CPE when enable_site_to_site_vpn is true."
  type        = string
  default     = null
}

variable "aws_backbone_cidrs" {
  description = "AWS CIDR ranges reachable from OCI via DRG/VPN routes."
  type        = list(string)
  default     = ["10.94.0.0/16"]
}

variable "enable_backbone_alert_topic" {
  description = "Create an OCI Notifications topic for hybrid backbone operations alerts."
  type        = bool
  default     = true
}

variable "backbone_alert_topic_name" {
  description = "Optional name for the hybrid backbone alerts topic."
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
