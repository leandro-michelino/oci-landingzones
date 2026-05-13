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
  description = "Compartment OCID where networking resources are deployed. Defaults to tenancy_ocid for simple tests."
  type        = string
  default     = null
}

variable "enable_bastion" {
  description = "Create an OCI Bastion service endpoint in the hub VCN."
  type        = bool
  default     = false
}

variable "bastion_label" {
  description = "Short semantic label for the bastion."
  type        = string
  default     = "hub"
}

variable "bastion_subnet_key" {
  description = "Hub subnet key where the bastion endpoint is placed."
  type        = string
  default     = "shared"
}

variable "client_cidr_block_allow_list" {
  description = "Client CIDR blocks allowed to create bastion sessions."
  type        = list(string)
  default     = []

  validation {
    condition = (
      !var.enable_bastion ||
      (
        length(var.client_cidr_block_allow_list) > 0 &&
        alltrue([
          for cidr in var.client_cidr_block_allow_list :
          !contains(["0.0.0.0/0", "::/0"], cidr)
        ])
      )
    )
    error_message = "Set at least one specific client CIDR when enable_bastion is true; 0.0.0.0/0 and ::/0 are not allowed."
  }
}

variable "max_session_ttl_in_seconds" {
  description = "Maximum session TTL for bastion sessions."
  type        = number
  default     = 3600
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
