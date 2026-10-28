variable "project_id" {
  description = "Existing Google project with billing and required APIs pre-enabled."
  type        = string
}

variable "region" {
  description = "Explicit approved GCP region."
  type        = string
}

variable "name" {
  description = "Unique lowercase resource prefix; examples are not live destinations."
  type        = string
}

variable "enabled" {
  description = "Create GCP foundation only after reviewed approval."
  type        = bool
  default     = false
}

variable "costs_approved" {
  description = "Explicit approval of billed GCP dependencies."
  type        = bool
  default     = false
}

variable "subnet_cidr" {
  description = "Private workload subnet range."
  type        = string
  default     = "10.96.10.0/24"
}

variable "peer_cidrs" {
  description = "Reviewed OCI workload prefixes."
  type        = set(string)
  default     = ["10.95.10.0/24"]
}

variable "allowed_tcp_ports" {
  description = "Explicit VM ingress ports; applies only to tagged VM NICs."
  type        = set(number)
  default     = []
}

variable "enable_nat" {
  description = "Optional paid Cloud NAT and Internet route."
  type        = bool
  default     = false
}

variable "enable_workload" {
  description = "Create the pattern-specific workload resources; paid and disabled by default."
  type        = bool
  default     = false
}

variable "activate_attachments" {
  description = "Preactivate attachments only after approved staged partner provisioning."
  type        = bool
  default     = false
}

variable "enable_bgp" {
  description = "Configure BGP only after reviewing partner-assigned interface addresses."
  type        = bool
  default     = false
}

variable "bgp_sessions" {
  description = "Approved primary/secondary peering IPs with CIDR suffixes; copy actual assigned values."
  type        = map(object({ customer_ip = string, oracle_ip = string, peer_asn = number }))
  default     = {}
}

variable "enable_vpn" {
  description = "Create GCP HA VPN gateway and independent VPN Cloud Router."
  type        = bool
  default     = false
}

variable "enable_vpn_tunnels" {
  description = "Create all four IKEv2 VPN tunnels and BGP interfaces after OCI endpoint discovery."
  type        = bool
  default     = false
}

variable "vpn_asn" {
  description = "Reviewed private ASN for the VPN-specific Cloud Router."
  type        = number
  default     = 64514
}

variable "oci_vpn_asn" {
  description = "Actual OCI VPN BGP ASN; verify from OCI before enabling tunnels."
  type        = number
  default     = 31898
}

variable "vpn_tunnels" {
  description = "Four OCI endpoint mappings with explicit external and HA gateway interface indices."
  type        = map(object({ peer_interface = number, gateway_interface = number, oracle_public_ip = string, customer_ip = string, oracle_ip = string }))
  default     = {}
}

variable "vpn_psks" {
  description = "Sensitive keys matching the OCI managed tunnels."
  type        = map(string)
  default     = {}
  sensitive   = true
}
