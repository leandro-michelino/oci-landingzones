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

variable "enable_database" {
  description = "Create paid OCI primary MySQL DB System."
  type        = bool
  default     = false
}

variable "enable_heatwave" {
  description = "Create paid optional HeatWave analytics cluster; not replicated as analytics capacity to Cloud SQL."
  type        = bool
  default     = false
}

variable "availability_domain" {
  description = "Explicit OCI database availability domain."
  type        = string
  default     = null
}

variable "db_shape_name" {
  description = "Reviewed supported MySQL shape."
  type        = string
  default     = null
}

variable "admin_username" {
  description = "Database administrator name."
  type        = string
  default     = "lzadmin"
}

variable "admin_password" {
  description = "Sensitive password supplied only through protected inputs."
  type        = string
  default     = null
  sensitive   = true
}
