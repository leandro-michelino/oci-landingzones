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

variable "aws_region" {
  description = "AWS region supported by the managed interconnect offering."
  type        = string
}

variable "aws_account_id" {
  description = "AWS account that accepts the activation key."
  type        = string
}

variable "aws_profile" {
  description = "Optional AWS named profile; null uses the normal AWS credential chain."
  type        = string
  default     = null
}

variable "aws_vpc_cidr" {
  description = "AWS VPC CIDR."
  type        = string
  default     = "10.96.0.0/16"
}

variable "aws_az" {
  description = "Explicit AWS subnet availability zone in the selected region."
  type        = string
}

variable "aws_dx_asn" {
  description = "Direct Connect gateway ASN, different from VGW ASN."
  type        = number
  default     = 64512
}

variable "aws_vgw_asn" {
  description = "Virtual private gateway ASN."
  type        = number
  default     = 64513
}


variable "region_pair_verified" {
  description = "Operator confirmed current offering, region pair, account eligibility and bandwidth with both providers."
  type        = bool
  default     = false
}
