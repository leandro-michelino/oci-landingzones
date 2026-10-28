variable "tenancy_ocid" {
  description = "OCI tenancy identifier."
  type        = string
}

variable "compartment_ocid" {
  description = "Explicit OCI compartment; no tenancy-root fallback."
  type        = string
}

variable "region" {
  description = "OCI region in a supported interconnect region pair."
  type        = string
}

variable "oci_config_profile" {
  description = "OCI configuration profile."
  type        = string
  default     = "DEFAULT"
}

variable "org" {
  description = "Organization naming token."
  type        = string
}

variable "environment" {
  description = "Environment naming token."
  type        = string
}

variable "region_key" {
  description = "OCI short region naming token."
  type        = string
}

variable "enable_foundation" {
  description = "Create isolated networking in both clouds."
  type        = bool
  default     = false
}

variable "enable_interconnect" {
  description = "Create the OCI virtual circuit resources; partner activation remains required."
  type        = bool
  default     = false
}

variable "costs_approved" {
  description = "Operator approval of billed network dependencies before circuit creation."
  type        = bool
  default     = false
}

variable "provider_service_id" {
  description = "Region-specific FastConnect provider service OCID, verified for the selected offering."
  type        = string
  default     = null
}

variable "bandwidth_shape_name" {
  description = "An available provider bandwidth shape; confirm for selected region pair."
  type        = string
  default     = "1 Gbps"
}

variable "oci_vcn_cidr" {
  description = "OCI private VCN CIDR."
  type        = string
  default     = "10.56.0.0/16"
}

variable "oci_subnet_cidr" {
  description = "OCI private workload subnet CIDR."
  type        = string
  default     = "10.56.10.0/24"
}

variable "remote_subnet_cidr" {
  description = "Remote subnet prefix; must not overlap OCI."
  type        = string
  default     = "10.96.10.0/24"
}

variable "allowed_tcp_ports" {
  description = "Explicit cross-cloud application ports; empty means no permitted application ingress."
  type        = set(number)
  default     = []
}

variable "defined_tags" {
  description = "Existing OCI defined tags."
  type        = map(string)
  default     = {}
}

variable "freeform_tags" {
  description = "OCI freeform tags."
  type        = map(string)
  default     = {}
}

variable "gcp_project_id" {
  description = "Existing Google Cloud project with billing and Compute API enabled."
  type        = string
}

variable "gcp_region" {
  description = "Google Cloud region supported with the selected OCI region."
  type        = string
}

variable "enable_bgp" {
  description = "Configure Google router interfaces and BGP after partner provisioning."
  type        = bool
  default     = false
}

variable "activate_attachments" {
  description = "Preactivate both Partner VLAN attachments after operator review."
  type        = bool
  default     = false
}

variable "gcp_router_asn" {
  description = "Cloud Router ASN; Partner Interconnect uses 16550."
  type        = number
  default     = 16550
}

variable "bgp_sessions" {
  description = "Approved BGP addresses per edge (primary and secondary); use assigned partner values."
  type        = map(object({ google_ip_cidr = string, oracle_ip_cidr = string }))
  default     = {}
}


variable "region_pair_verified" {
  description = "Operator confirmed current offering, region pair, account eligibility and bandwidth with both providers."
  type        = bool
  default     = false
}
