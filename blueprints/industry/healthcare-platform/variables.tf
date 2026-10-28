variable "tenancy_ocid" {
  description = "OCI tenancy OCID."
  type        = string
}

variable "compartment_ocid" {
  description = "Explicit workload compartment OCID; no tenancy fallback."
  type        = string
}

variable "region" {
  description = "Approved region for this single-region project."
  type        = string
}

variable "oci_config_profile" {
  description = "OCI configuration profile."
  type        = string
  default     = "DEFAULT"
  validation {
    condition     = var.oci_config_profile == "DEFAULT"
    error_message = "This blueprint uses only the DEFAULT profile."
  }
}

variable "org" {
  description = "Organization naming prefix."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "region_key" {
  description = "Short region naming key."
  type        = string
}

variable "enable_foundation" {
  description = "Create the private network and network logging."
  type        = bool
  default     = false
}

variable "costs_approved" {
  description = "Explicit approval for the selected billed resources; not a cost estimate."
  type        = bool
  default     = false
}

variable "enable_application" {
  description = "Create private Compute and internal HTTPS load balancing."
  type        = bool
  default     = false
}

variable "enable_database" {
  description = "Create private Autonomous Database."
  type        = bool
  default     = false
}

variable "enable_documents" {
  description = "Create the private encrypted document bucket."
  type        = bool
  default     = false
}

variable "vcn_cidr" {
  description = "Illustrative IPv4 VCN range; replace after address review."
  type        = string
  default     = "10.120.0.0/16"
}

variable "subnet_cidrs" {
  description = "Three non-overlapping private subnet ranges inside the VCN."
  type        = map(string)
  default     = { ingress = "10.120.10.0/24", application = "10.120.20.0/24", database = "10.120.30.0/24" }
}

variable "hospital_client_cidrs" {
  description = "Approved hospital client prefixes; never an Internet-wide prefix."
  type        = set(string)
  default     = []
}

variable "drg_id" {
  description = "Existing DRG with external hospital transport and route exchange already configured."
  type        = string
  default     = null
}

variable "kms_key_id" {
  description = "Existing approved KMS key for boot volumes, database and document storage."
  type        = string
  default     = null
}

variable "kms_policies_ready" {
  description = "Operator acknowledgement that resource/service principals have required KMS permissions."
  type        = bool
  default     = false
}

variable "boot_volume_backup_policy_id" {
  description = "Existing reviewed backup policy assigned to every application boot volume."
  type        = string
  default     = null
}

variable "application_shape" {
  description = "Example flexible shape; regional availability and capacity require review."
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "application_ocpus" {
  description = "Example OCPU allocation per application VM."
  type        = number
  default     = 2
}

variable "application_memory_gbs" {
  description = "Example memory allocation per application VM."
  type        = number
  default     = 16
}

variable "tls_public_certificate" {
  description = "PEM frontend certificate; certificate identity and chain require operator verification."
  type        = string
  default     = null
}

variable "tls_private_key" {
  description = "PEM frontend private key; sensitive and stored in Terraform state."
  type        = string
  default     = null
  sensitive   = true
}

variable "tls_ca_certificate" {
  description = "PEM frontend intermediate certificate chain, if required."
  type        = string
  default     = null
}

variable "backend_trusted_ca_ids" {
  description = "Existing OCI certificate-authority OCIDs trusted for backend HTTPS peer validation."
  type        = set(string)
  default     = []
}

variable "database_name" {
  description = "Autonomous Database name."
  type        = string
  default     = "HEALTHAPP"
}

variable "database_admin_password" {
  description = "Initial ADMIN password; sensitive and stored in Terraform state."
  type        = string
  default     = null
  sensitive   = true
}

variable "database_ecpus" {
  description = "Example database ECPU count; not sizing advice."
  type        = number
  default     = 2
}

variable "database_storage_tbs" {
  description = "Example database storage in TB; not a cost estimate."
  type        = number
  default     = 1
}

variable "database_backup_days" {
  description = "Autonomous automated backup retention; customer retention requirements remain external."
  type        = number
  default     = 31
}

variable "defined_tags" {
  description = "Approved defined tags."
  type        = map(string)
  default     = {}
}

variable "freeform_tags" {
  description = "Non-sensitive freeform tags; never patient identifiers."
  type        = map(string)
  default     = {}
}

variable "application_instances" {
  description = "Approved prebuilt HTTPS application images keyed by stable node name; no clinical application is installed by this blueprint."
  type        = map(object({ availability_domain = string, image_id = string }))
  default     = {}
}
