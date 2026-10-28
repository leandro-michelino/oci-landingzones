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

variable "kms_key_id" {
  description = "Existing approved KMS key for the optional integration-event Queue."
  type        = string
  default     = null
}

variable "kms_policies_ready" {
  description = "Operator acknowledgement that resource/service principals have required KMS permissions."
  type        = bool
  default     = false
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

variable "enable_api" {
  description = "Create the private authenticated FHIR HTTP proxy; no FHIR server is installed."
  type        = bool
  default     = false
}

variable "enable_queue" {
  description = "Create an encrypted integration-event queue; no producer or consumer is installed."
  type        = bool
  default     = false
}

variable "vcn_cidr" {
  description = "Example integration VCN, distinct from the patient-data blueprint."
  type        = string
  default     = "10.121.0.0/16"
}

variable "subnet_cidrs" {
  description = "Private api and integration subnets inside the VCN."
  type        = map(string)
  default     = { api = "10.121.10.0/24", integration = "10.121.20.0/24" }
}

variable "drg_id" {
  description = "Existing DRG with private hospital/backend/JWKS connectivity."
  type        = string
  default     = null
}

variable "hospital_client_cidrs" {
  description = "Approved private FHIR client prefixes."
  type        = set(string)
  default     = []
}

variable "fhir_backend_cidrs" {
  description = "Approved private FHIR backend prefixes routed through the existing DRG."
  type        = set(string)
  default     = []
}

variable "jwks_cidrs" {
  description = "Approved private prefixes hosting the unauthenticated HTTPS JWKS endpoint."
  type        = set(string)
  default     = []
}

variable "fhir_backend_url" {
  description = "Existing HTTPS FHIR R4 base URL, including its /fhir path if applicable."
  type        = string
  default     = null
}

variable "fhir_backend_authorization_ready" {
  description = "Operator acknowledgement of backend patient/resource authorization; not an enforcement test."
  type        = bool
  default     = false
}

variable "jwks_uri" {
  description = "Existing HTTPS public-key set URI; reachable over the private route, without authentication."
  type        = string
  default     = null
}

variable "jwt_issuers" {
  description = "Exact trusted issuer claim values."
  type        = set(string)
  default     = []
}

variable "jwt_audiences" {
  description = "Exact trusted audience claim values."
  type        = set(string)
  default     = []
}

variable "gateway_certificate_id" {
  description = "Optional existing OCI certificate OCID for the private gateway."
  type        = string
  default     = null
}

variable "fhir_resources" {
  description = "Explicit FHIR resource route allowlist; not a FHIR profile validator."
  type        = set(string)
  default     = ["Patient", "Encounter", "Observation", "DiagnosticReport", "DocumentReference"]
}

variable "allowed_methods" {
  description = "Resource methods; GET only by default, no DELETE route."
  type        = set(string)
  default     = ["GET"]
}

variable "queue_retention_seconds" {
  description = "Integration reference-event retention in seconds; payload approval remains external."
  type        = number
  default     = 86400
}

variable "ca_bundle_ids" {
  description = "Existing OCI CA bundle OCIDs for outbound private-PKI backend/JWKS trust where required."
  type        = set(string)
  default     = []
}
