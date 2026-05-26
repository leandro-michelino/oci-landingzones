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
  description = "Compartment OCID where OCI transit resources are created. Defaults to tenancy_ocid for validation-only tests."
  type        = string
  default     = null
}

variable "existing_drg_id" {
  description = "Optional existing DRG OCID to reuse for London or quota-constrained tests. When set, the blueprint does not create or destroy a DRG."
  type        = string
  default     = null
}

variable "oci_is_primary" {
  description = "Set to true. This pattern keeps OCI DRG as the primary transit hub."
  type        = bool
  default     = true

  validation {
    condition     = var.oci_is_primary == true
    error_message = "oci_is_primary must be true for this blueprint variant."
  }
}

variable "enable_oci_primary_network" {
  description = "Create OCI network resources (VCN, route table, security list, and hub subnet) for the primary transit domain."
  type        = bool
  default     = true
}

variable "oci_primary_vcn_cidr" {
  description = "CIDR block for OCI primary transit VCN when enable_oci_primary_network is true."
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

variable "azure_virtual_wan_id" {
  description = "Azure Virtual WAN resource ID for transit contract tracking."
  type        = string
  default     = null
}

variable "azure_virtual_hub_id" {
  description = "Azure Virtual Hub resource ID for transit contract tracking."
  type        = string
  default     = null
}

variable "azure_virtual_hub_region" {
  description = "Azure region for Virtual WAN and Virtual Hub resources in contract outputs."
  type        = string
  default     = "westeurope"
}

variable "azure_virtual_hub_address_prefix" {
  description = "Azure Virtual Hub address prefix documented in transit contract outputs."
  type        = string
  default     = "10.89.255.0/24"
}

variable "azure_route_table_name" {
  description = "Azure Virtual Hub route table name expected for OCI transit path advertisement."
  type        = string
  default     = "rt-vhub-oci-transit"
}

variable "enable_route_segmentation" {
  description = "Enable route segmentation contract metadata for prod, nonprod, and management lanes."
  type        = bool
  default     = true
}

variable "transit_segments" {
  description = "Segment-to-CIDR mapping for transit route policy reviews."
  type = object({
    prod       = list(string)
    nonprod    = list(string)
    management = list(string)
  })
  default = {
    prod       = ["10.88.10.0/24"]
    nonprod    = ["10.88.20.0/24"]
    management = ["10.88.30.0/24"]
  }
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
  description = "Azure BGP ASN recorded in transit contracts for operational validation."
  type        = number
  default     = 65515
}

variable "azure_network_cidrs" {
  description = "Azure CIDR ranges reachable from OCI over interconnect and or IPSec fallback."
  type        = list(string)
  default     = ["10.88.0.0/16"]
}

variable "bgp_keepalive_seconds" {
  description = "BGP keepalive interval in seconds documented in the transit hardening contract."
  type        = number
  default     = 20
}

variable "bgp_hold_seconds" {
  description = "BGP hold timer in seconds documented in the transit hardening contract."
  type        = number
  default     = 60
}

variable "enable_transit_alert_topic" {
  description = "Create an OCI Notifications topic for transit events and fallback alerts."
  type        = bool
  default     = true
}

variable "transit_alert_topic_name" {
  description = "Optional name for the transit alert topic."
  type        = string
  default     = null
}

variable "enable_dns_contract" {
  description = "Publish private DNS forwarding and resolution contract metadata."
  type        = bool
  default     = true
}

variable "private_dns_zone_fqdn" {
  description = "Private DNS zone name represented in the transit contract (for example corp.internal)."
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
  default     = "transit-probe.example.internal"
}

variable "target_convergence_seconds" {
  description = "Target maximum route convergence time in seconds for operations runbooks."
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
