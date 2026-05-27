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
  description = "Compartment OCID where Digital Assistant resources are created. Defaults to tenancy_ocid for validation-only tests."
  type        = string
  default     = null
}

variable "enable_oda_network" {
  description = "Create deploy-and-use network resources for ODA private endpoint placement."
  type        = bool
  default     = true
}

variable "oda_vcn_cidr" {
  description = "CIDR block for ODA VCN when enable_oda_network is true."
  type        = string
  default     = "10.86.0.0/16"
}

variable "oda_subnet_cidr" {
  description = "CIDR block for ODA private endpoint subnet when enable_oda_network is true."
  type        = string
  default     = "10.86.10.0/24"
}

variable "oda_ingress_allowed_cidr" {
  description = "Source CIDR allowed to access ODA private endpoint HTTPS."
  type        = string
  default     = "10.0.0.0/8"
}

variable "oda_egress_allowed_cidr" {
  description = "Destination CIDR allowed for ODA private endpoint HTTPS egress."
  type        = string
  default     = "10.0.0.0/8"
}

variable "create_oda_instance" {
  description = "Create Oracle Digital Assistant instance."
  type        = bool
  default     = true
}

variable "oda_instance_id" {
  description = "Existing ODA instance OCID when create_oda_instance is false."
  type        = string
  default     = null
}

variable "oda_display_name" {
  description = "Optional ODA instance display name override."
  type        = string
  default     = null
}

variable "oda_description" {
  description = "ODA instance description."
  type        = string
  default     = "Digital assistant instance managed by OCI landing zones blueprint."
}

variable "oda_shape_name" {
  description = "ODA shape name."
  type        = string
  default     = "DEVELOPMENT"
}

variable "oda_identity_domain" {
  description = "Optional identity domain for ODA instance."
  type        = string
  default     = null
}

variable "oda_is_role_based_access" {
  description = "Enable role-based access mode for ODA instance."
  type        = bool
  default     = true
}

variable "create_oda_private_endpoint" {
  description = "Create ODA private endpoint."
  type        = bool
  default     = true
}

variable "oda_private_endpoint_id" {
  description = "Existing ODA private endpoint OCID when create_oda_private_endpoint is false."
  type        = string
  default     = null
}

variable "oda_private_endpoint_display_name" {
  description = "Optional ODA private endpoint display name override."
  type        = string
  default     = null
}

variable "oda_private_endpoint_description" {
  description = "Description for ODA private endpoint."
  type        = string
  default     = "ODA private endpoint for integration and bot traffic."
}

variable "oda_private_endpoint_subnet_id" {
  description = "Existing subnet OCID for ODA private endpoint when enable_oda_network is false."
  type        = string
  default     = null
}

variable "oda_private_endpoint_additional_nsg_ids" {
  description = "Additional NSG OCIDs to attach to ODA private endpoint."
  type        = set(string)
  default     = []
}

variable "attach_private_endpoint_to_instance" {
  description = "Attach ODA private endpoint to ODA instance."
  type        = bool
  default     = true
}

variable "create_alert_topic" {
  description = "Create a notifications topic for ODA operations and channel alerts."
  type        = bool
  default     = true
}

variable "alert_topic_name" {
  description = "Optional notifications topic name override."
  type        = string
  default     = null
}

variable "policy_compartment_ocid" {
  description = "Compartment OCID where IAM policy is created. Defaults to tenancy_ocid."
  type        = string
  default     = null
}

variable "policy_statements" {
  description = "IAM policy statements for ODA operators, developers, and integration callers."
  type        = list(string)
  default     = []
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
