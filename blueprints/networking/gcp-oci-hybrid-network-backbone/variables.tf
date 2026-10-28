variable "tenancy_ocid" {
  description = "Existing OCI tenancy OCID."
  type        = string
}

variable "current_user_ocid" {
  description = "Operator identity metadata; authentication uses DEFAULT."
  type        = string
}

variable "compartment_ocid" {
  description = "Explicit OCI workload compartment; no tenancy fallback."
  type        = string
}

variable "region" {
  description = "Approved OCI region."
  type        = string
}

variable "home_region" {
  description = "Home region when a pinned child provider requires it."
  type        = string
  default     = null
}

variable "oci_config_profile" {
  description = "OCI CLI profile; DEFAULT unless explicitly changed."
  type        = string
  default     = "DEFAULT"
}

variable "org" {
  description = "Organization naming prefix."
  type        = string
  default     = "example"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "dev"
}

variable "region_key" {
  description = "Short OCI region key."
  type        = string
  default     = "gru"
}

variable "enable_oci" {
  description = "Enable this OCI foundation only after review."
  type        = bool
  default     = false
}

variable "costs_approved" {
  description = "Explicit approval of potentially billed resources."
  type        = bool
  default     = false
}

variable "peer_cidr" {
  description = "Approved GCP workload subnet CIDR; not discovered automatically."
  type        = string
  default     = "10.96.10.0/24"
}

variable "oci_vcn_id" {
  description = "Existing OCVS-independent OCI workload VCN where required."
  type        = string
  default     = null
}

variable "oci_subnet_id" {
  description = "Existing private OCI service or endpoint subnet where required."
  type        = string
  default     = null
}

variable "oci_vcn_cidr" {
  description = "VCN range for a new foundation."
  type        = string
  default     = "10.95.0.0/16"
}

variable "oci_subnet_cidr" {
  description = "Private OCI workload subnet range."
  type        = string
  default     = "10.95.10.0/24"
}

variable "allowed_tcp_ports" {
  description = "Explicit cross-cloud ingress ports; empty denies new ingress."
  type        = set(number)
  default     = []
}

variable "connectivity_verified" {
  description = "Operator attestation after circuit/VPN, routes, DNS and traffic acceptance; not a test result."
  type        = bool
  default     = false
}

variable "enable_interconnect" {
  description = "Request partner FastConnect using pairing keys from the separate GCP root."
  type        = bool
  default     = false
}

variable "region_pair_verified" {
  description = "Offering and exact region-pair eligibility reviewed with providers."
  type        = bool
  default     = false
}

variable "provider_service_id" {
  description = "Approved OCI FastConnect provider service OCID."
  type        = string
  default     = null
}

variable "circuits" {
  description = "Partner circuits keyed by primary and secondary; populate only after assigned addressing is verified."
  type        = map(object({ pairing_key = string, bandwidth = string, customer_asn = number, customer_ip = string, oracle_ip = string }))
  default     = {}
}

variable "enable_vpn" {
  description = "Create two OCI IPSec connections after GCP HA VPN public addresses are assigned."
  type        = bool
  default     = false
}

variable "gcp_vpn_public_ips" {
  description = "Two Google HA VPN public addresses keyed primary and secondary."
  type        = map(string)
  default     = {}
}

variable "gcp_vpn_asn" {
  description = "GCP VPN Cloud Router ASN; separate from Partner Interconnect ASN 16550."
  type        = number
  default     = 64514
}

variable "vpn_tunnels" {
  description = "Four tunnel management bindings from discovered OCI tunnel IDs and reviewed inside addresses."
  type        = map(object({ edge_key = string, tunnel_id = string, customer_ip = string, oracle_ip = string }))
  default     = {}
}

variable "vpn_psks" {
  description = "Sensitive per-tunnel pre-shared keys kept in protected inputs."
  type        = map(string)
  default     = {}
  sensitive   = true
}
