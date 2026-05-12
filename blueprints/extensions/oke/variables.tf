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
  description = "Compartment OCID where OKE resources are created. Defaults to tenancy_ocid for validation-only tests."
  type        = string
  default     = null
}

variable "enable_cluster" {
  description = "Create the OKE cluster. Disabled by default to avoid cost in smoke tests."
  type        = bool
  default     = false
}

variable "cluster_id" {
  description = "Existing OKE cluster OCID used when creating only a node pool."
  type        = string
  default     = null
}

variable "cluster_label" {
  description = "Short OKE cluster label used in names."
  type        = string
  default     = "platform"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the OKE cluster and node pool."
  type        = string
  default     = null
}

variable "vcn_id" {
  description = "VCN OCID where the OKE cluster is created."
  type        = string
  default     = null
}

variable "endpoint_subnet_id" {
  description = "Optional subnet OCID for the OKE Kubernetes API endpoint."
  type        = string
  default     = null
}

variable "endpoint_public_ip_enabled" {
  description = "Whether the OKE API endpoint receives a public IP."
  type        = bool
  default     = false
}

variable "endpoint_nsg_ids" {
  description = "Optional NSG OCIDs for the OKE API endpoint."
  type        = set(string)
  default     = []
}

variable "service_lb_subnet_ids" {
  description = "Optional subnet OCIDs used by OKE service load balancers."
  type        = list(string)
  default     = []
}

variable "cni_type" {
  description = "OKE pod networking CNI type."
  type        = string
  default     = "OCI_VCN_IP_NATIVE"
}

variable "enable_node_pool" {
  description = "Create an OKE node pool. Disabled by default to avoid compute cost."
  type        = bool
  default     = false
}

variable "node_pool_label" {
  description = "Short node pool label used in names."
  type        = string
  default     = "workers"
}

variable "node_shape" {
  description = "OKE worker node shape."
  type        = string
  default     = null
}

variable "node_shape_ocpus" {
  description = "Optional OCPU count for flexible node shapes."
  type        = number
  default     = null
}

variable "node_shape_memory_in_gbs" {
  description = "Optional memory in GB for flexible node shapes."
  type        = number
  default     = null
}

variable "node_subnet_ids" {
  description = "Subnet OCIDs used by the OKE node pool."
  type        = set(string)
  default     = []
}

variable "node_quantity_per_subnet" {
  description = "Number of nodes per node subnet."
  type        = number
  default     = 1
}

variable "node_image_id" {
  description = "Optional custom worker node image OCID."
  type        = string
  default     = null
}

variable "ssh_public_key" {
  description = "Optional SSH public key for worker nodes."
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
