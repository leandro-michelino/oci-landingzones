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
  description = "Compartment OCID where OCI dual connectivity resources are created. Defaults to tenancy_ocid for validation-only tests."
  type        = string
  default     = null
}

variable "oci_is_primary" {
  description = "Set to true. This pattern keeps OCI DRG as the primary cross-cloud routing hub."
  type        = bool
  default     = true

  validation {
    condition     = var.oci_is_primary == true
    error_message = "oci_is_primary must be true for this blueprint variant."
  }
}

variable "enable_oci_primary_network" {
  description = "Create OCI network resources (VCN, route table, security list, and hub subnet) for the primary connectivity domain."
  type        = bool
  default     = true
}

variable "existing_oci_primary_vcn_id" {
  description = "Existing OCI VCN OCID to reuse instead of creating a new primary VCN."
  type        = string
  default     = null

  validation {
    condition     = !(var.enable_oci_primary_network && var.existing_oci_primary_vcn_id != null)
    error_message = "Set either enable_oci_primary_network=true (create VCN) or existing_oci_primary_vcn_id (reuse VCN), not both."
  }
}

variable "oci_primary_vcn_cidr" {
  description = "CIDR block for OCI primary VCN when enable_oci_primary_network is true."
  type        = string
  default     = "10.58.0.0/16"
}

variable "oci_primary_hub_subnet_cidr" {
  description = "CIDR block for OCI primary hub subnet when enable_oci_primary_network is true."
  type        = string
  default     = "10.58.10.0/24"
}

variable "oci_primary_ingress_allowed_cidr" {
  description = "Source CIDR allowed for OCI primary hub subnet ingress over HTTPS."
  type        = string
  default     = "10.0.0.0/8"
}

variable "existing_oci_primary_drg_id" {
  description = "Existing OCI DRG OCID to reuse instead of creating a new DRG."
  type        = string
  default     = null
}

variable "attach_oci_primary_vcn_to_drg" {
  description = "Attach OCI primary VCN to the effective DRG. Disable when reusing a VCN that is already attached."
  type        = bool
  default     = true
}

variable "connectivity_mode" {
  description = "Connectivity mode between OCI and Azure: without-interconnect (IPSec first) or interconnect."
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

variable "expressroute_circuit_id" {
  description = "Azure ExpressRoute circuit resource ID used when connectivity_mode is interconnect."
  type        = string
  default     = null
}

variable "enable_ipsec_fallback" {
  description = "Create OCI CPE and IPSec resources for fallback path when interconnect is unavailable."
  type        = bool
  default     = true
}

variable "azure_cpe_public_ip" {
  description = "Public IP address of the Azure VPN endpoint used for OCI CPE when enable_ipsec_fallback is true."
  type        = string
  default     = null
}

variable "azure_bgp_asn" {
  description = "Azure BGP ASN recorded in routing contracts for operational validation."
  type        = number
  default     = 65515
}

variable "azure_network_cidrs" {
  description = "Azure CIDR ranges reachable from OCI over interconnect and/or IPSec fallback."
  type        = list(string)
  default     = ["10.88.0.0/16"]
}

variable "bgp_keepalive_seconds" {
  description = "BGP keepalive interval in seconds documented in the routing hardening contract."
  type        = number
  default     = 20
}

variable "bgp_hold_seconds" {
  description = "BGP hold timer in seconds documented in the routing hardening contract."
  type        = number
  default     = 60
}

variable "enable_connectivity_alert_topic" {
  description = "Create an OCI Notifications topic for connectivity events and fallback alerts."
  type        = bool
  default     = true
}

variable "connectivity_alert_topic_name" {
  description = "Optional name for the connectivity alert topic."
  type        = string
  default     = null
}

variable "enable_dns_contract" {
  description = "Publish private DNS forwarding and resolution contract metadata."
  type        = bool
  default     = true
}

variable "private_dns_zone_fqdn" {
  description = "Private DNS zone name represented in the connectivity contract (for example corp.internal)."
  type        = string
  default     = "corp.internal"
}

variable "oci_dns_resolver_endpoint" {
  description = "OCI DNS resolver endpoint recorded in DNS contract outputs."
  type        = string
  default     = null
}

variable "azure_dns_resolver_endpoint" {
  description = "Azure DNS resolver endpoint recorded in DNS contract outputs."
  type        = string
  default     = null
}

variable "health_probe_fqdn" {
  description = "FQDN used by operators to validate active path and failback readiness."
  type        = string
  default     = "connectivity-probe.example.internal"
}

variable "target_failover_seconds" {
  description = "Target maximum path failover time in seconds for operations runbooks."
  type        = number
  default     = 120
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
