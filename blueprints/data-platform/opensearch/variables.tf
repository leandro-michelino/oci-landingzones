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
  description = "Compartment OCID where resources are created. Defaults to tenancy_ocid for validation-only tests."
  type        = string
  default     = null
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

variable "create_cluster" {
  description = "Create an OCI Search with OpenSearch cluster."
  type        = bool
  default     = false
}
variable "cluster_display_name" {
  description = "Optional OpenSearch cluster display name override."
  type        = string
  default     = null
}
variable "software_version" {
  description = "OpenSearch software version."
  type        = string
  default     = "2.11.0"
}
variable "vcn_id" {
  description = "VCN OCID for the OpenSearch cluster."
  type        = string
  default     = null
}
variable "vcn_compartment_id" {
  description = "VCN compartment OCID. Defaults to compartment_ocid."
  type        = string
  default     = null
}
variable "subnet_id" {
  description = "Subnet OCID for the OpenSearch cluster."
  type        = string
  default     = null
}
variable "subnet_compartment_id" {
  description = "Subnet compartment OCID. Defaults to compartment_ocid."
  type        = string
  default     = null
}
variable "nsg_id" {
  description = "Optional NSG OCID for the OpenSearch cluster."
  type        = string
  default     = null
}
variable "master_node_count" {
  description = "OpenSearch master node count."
  type        = number
  default     = 1
}
variable "master_node_host_type" {
  description = "Master node host type."
  type        = string
  default     = "FLEX"
}
variable "master_node_host_ocpu_count" {
  description = "Master node OCPU count."
  type        = number
  default     = 1
}
variable "master_node_host_memory_gb" {
  description = "Master node memory in GB."
  type        = number
  default     = 16
}
variable "data_node_count" {
  description = "OpenSearch data node count."
  type        = number
  default     = 1
}
variable "data_node_host_type" {
  description = "Data node host type."
  type        = string
  default     = "FLEX"
}
variable "data_node_host_ocpu_count" {
  description = "Data node OCPU count."
  type        = number
  default     = 1
}
variable "data_node_host_memory_gb" {
  description = "Data node memory in GB."
  type        = number
  default     = 16
}
variable "data_node_storage_gb" {
  description = "Data node storage in GB."
  type        = number
  default     = 50
}
variable "opendashboard_node_count" {
  description = "OpenSearch Dashboard node count."
  type        = number
  default     = 1
}
variable "opendashboard_node_host_ocpu_count" {
  description = "OpenSearch Dashboard OCPU count."
  type        = number
  default     = 1
}
variable "opendashboard_node_host_memory_gb" {
  description = "OpenSearch Dashboard memory in GB."
  type        = number
  default     = 8
}
variable "opendashboard_node_host_shape" {
  description = "Optional OpenSearch Dashboard shape."
  type        = string
  default     = null
}
variable "security_master_user_name" {
  description = "Optional OpenSearch security master user."
  type        = string
  default     = null
}
variable "security_master_user_password_hash" {
  description = "Optional OpenSearch security master password hash."
  type        = string
  default     = null
  sensitive   = true
}
variable "security_mode" {
  description = "Optional OpenSearch security mode."
  type        = string
  default     = null
}

variable "create_snapshot_bucket" {
  description = "Create an Object Storage bucket for snapshot exports and vector dataset backups."
  type        = bool
  default     = false
}
variable "snapshot_bucket_name" {
  description = "Optional snapshot bucket name override."
  type        = string
  default     = null
}
variable "snapshot_bucket_versioning" {
  description = "Snapshot bucket versioning setting."
  type        = string
  default     = "Enabled"
}
variable "kms_key_id" {
  description = "Optional KMS key OCID for snapshot bucket encryption."
  type        = string
  default     = null
}
variable "policy_compartment_ocid" {
  description = "Compartment OCID where the IAM policy is created. Defaults to tenancy_ocid."
  type        = string
  default     = null
}
variable "policy_statements" {
  description = "IAM policy statements for OpenSearch admins, index writers, and read-only consumers."
  type        = list(string)
  default     = []
}
