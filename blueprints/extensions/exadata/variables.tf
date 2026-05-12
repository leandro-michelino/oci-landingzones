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
  description = "Compartment OCID where Exadata resources are created. Defaults to tenancy_ocid for validation-only tests."
  type        = string
  default     = null
}

variable "enable_exadata_infrastructure" {
  description = "Create Exadata Cloud Infrastructure. Disabled by default because this is high-cost and quota-sensitive."
  type        = bool
  default     = false
}

variable "exadata_label" {
  description = "Short Exadata label used in names."
  type        = string
  default     = "db"
}

variable "availability_domain" {
  description = "Availability domain for Exadata infrastructure."
  type        = string
  default     = null
}

variable "shape" {
  description = "Exadata infrastructure shape."
  type        = string
  default     = null
}

variable "compute_count" {
  description = "Optional Exadata compute server count."
  type        = number
  default     = null
}

variable "storage_count" {
  description = "Optional Exadata storage server count."
  type        = number
  default     = null
}

variable "database_server_type" {
  description = "Optional Exadata database server type."
  type        = string
  default     = null
}

variable "storage_server_type" {
  description = "Optional Exadata storage server type."
  type        = string
  default     = null
}

variable "customer_contacts" {
  description = "Customer contacts for Exadata operational notifications."
  type = list(object({
    email = string
  }))
  default = []
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
