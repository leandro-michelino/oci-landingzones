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
  description = "Compartment OCID where the identity domain is created. Defaults to tenancy_ocid."
  type        = string
  default     = null
}

variable "enable_identity_domain" {
  description = "Create the identity domain."
  type        = bool
  default     = true
}

variable "domain_display_name" {
  description = "Optional display name for the identity domain."
  type        = string
  default     = null
}

variable "domain_description" {
  description = "Description for the identity domain."
  type        = string
  default     = "Landing zone identity domain managed by Terraform."
}

variable "license_type" {
  description = "OCI IAM identity domain license type."
  type        = string
  default     = "free"
}

variable "admin_email" {
  description = "Optional administrator email for the identity domain."
  type        = string
  default     = null
}

variable "admin_first_name" {
  description = "Optional administrator first name."
  type        = string
  default     = null
}

variable "admin_last_name" {
  description = "Optional administrator last name."
  type        = string
  default     = null
}

variable "admin_user_name" {
  description = "Optional administrator user name."
  type        = string
  default     = null
}

variable "is_hidden_on_login" {
  description = "Hide the domain on the login page."
  type        = bool
  default     = false
}

variable "is_notification_bypassed" {
  description = "Bypass identity-domain notification emails."
  type        = bool
  default     = false
}

variable "is_primary_email_required" {
  description = "Require primary email for domain users."
  type        = bool
  default     = true
}

variable "replica_regions" {
  description = "Optional identity domain replica regions."
  type        = set(string)
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
