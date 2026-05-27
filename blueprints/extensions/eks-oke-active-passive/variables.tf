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

variable "enable_oke_networking" {
  description = "Create OCI networking (VCN, route table, security lists, and subnets) for OKE deployment."
  type        = bool
  default     = true
}

variable "oke_vcn_cidr" {
  description = "CIDR block for the OCI VCN created when enable_oke_networking is true."
  type        = string
  default     = "10.42.0.0/16"
}

variable "oke_endpoint_subnet_cidr" {
  description = "CIDR block for the OKE control plane endpoint subnet when enable_oke_networking is true."
  type        = string
  default     = "10.42.10.0/24"
}

variable "oke_node_subnet_cidrs" {
  description = "CIDR blocks for OKE worker node subnets when enable_oke_networking is true."
  type        = list(string)
  default     = ["10.42.20.0/24"]
}

variable "oke_service_lb_subnet_cidr" {
  description = "CIDR block for OKE service load balancer subnet when enable_oke_networking is true."
  type        = string
  default     = "10.42.30.0/24"
}

variable "oke_api_allowed_cidr" {
  description = "Source CIDR allowed to reach the OKE API endpoint subnet security list."
  type        = string
  default     = "0.0.0.0/0"
}

variable "oke_node_ssh_allowed_cidr" {
  description = "Optional CIDR allowed for SSH ingress to OKE worker nodes."
  type        = string
  default     = null
}

variable "oke_service_lb_allowed_cidr" {
  description = "Optional CIDR allowed to reach public OKE service load balancers on HTTP and HTTPS."
  type        = string
  default     = "0.0.0.0/0"
}

variable "oke_node_subnet_prohibit_public_ip_on_vnic" {
  description = "Whether worker node subnet VNICs are prohibited from receiving public IPs."
  type        = bool
  default     = true
}

variable "interconnect_mode" {
  description = "Cross-cloud interconnect mode. This blueprint supports partner Direct Connect + FastConnect only."
  type        = string
  default     = "direct-connect-fastconnect-partner"

  validation {
    condition     = var.interconnect_mode == "direct-connect-fastconnect-partner"
    error_message = "interconnect_mode must be direct-connect-fastconnect-partner."
  }
}

variable "fastconnect_virtual_circuit_id" {
  description = "OCI FastConnect virtual circuit OCID used by the AWS partner interconnect path."
  type        = string
  default     = null
}

variable "direct_connect_connection_id" {
  description = "AWS Direct Connect connection resource ID paired with FastConnect through the partner."
  type        = string
  default     = null
}

variable "enable_ipsec_backup" {
  description = "Set to false. This OCI-primary pattern intentionally excludes IPSec backup paths."
  type        = bool
  default     = false

  validation {
    condition     = var.enable_ipsec_backup == false
    error_message = "enable_ipsec_backup must remain false for this interconnect-only pattern."
  }
}

variable "oci_is_primary" {
  description = "Set to true. This pattern keeps OCI as the primary traffic target."
  type        = bool
  default     = true

  validation {
    condition     = var.oci_is_primary == true
    error_message = "oci_is_primary must be true for this blueprint variant."
  }
}

variable "enable_oke_cluster" {
  description = "Create the OCI primary OKE cluster. Disabled by default to avoid cost in smoke tests."
  type        = bool
  default     = false
}

variable "enable_oke_node_pool" {
  description = "Create the OCI primary OKE node pool. Disabled by default to avoid compute cost."
  type        = bool
  default     = false
}

variable "oke_cluster_id" {
  description = "Existing OKE cluster OCID used when enable_oke_cluster is false and enable_oke_node_pool is true."
  type        = string
  default     = null
}

variable "oke_cluster_label" {
  description = "Short OKE cluster label used in generated names."
  type        = string
  default     = "oci-primary"
}

variable "oke_node_pool_label" {
  description = "Short OKE node pool label used in generated names."
  type        = string
  default     = "oci-workers"
}

variable "oke_kubernetes_version" {
  description = "Kubernetes version for the OKE cluster and node pool."
  type        = string
  default     = null
}

variable "oke_vcn_id" {
  description = "Existing VCN OCID used when enable_oke_networking is false."
  type        = string
  default     = null
}

variable "oke_endpoint_subnet_id" {
  description = "Existing subnet OCID for OKE Kubernetes API endpoint when enable_oke_networking is false."
  type        = string
  default     = null
}

variable "oke_endpoint_public_ip_enabled" {
  description = "Whether the OKE API endpoint receives a public IP."
  type        = bool
  default     = false
}

variable "oke_endpoint_nsg_ids" {
  description = "Optional NSG OCIDs for the OKE Kubernetes API endpoint."
  type        = list(string)
  default     = []
}

variable "oke_service_lb_subnet_ids" {
  description = "Existing subnet OCIDs used by OKE service load balancers when enable_oke_networking is false."
  type        = list(string)
  default     = []
}

variable "oke_cni_type" {
  description = "OKE pod networking CNI type."
  type        = string
  default     = null
}

variable "oke_node_shape" {
  description = "OKE worker node shape."
  type        = string
  default     = "VM.Standard.E5.Flex"
}

variable "oke_node_shape_ocpus" {
  description = "Optional OCPU count for flexible node shapes."
  type        = number
  default     = null
}

variable "oke_node_shape_memory_in_gbs" {
  description = "Optional memory in GB for flexible node shapes."
  type        = number
  default     = null
}

variable "oke_node_subnet_ids" {
  description = "Existing subnet OCIDs used by the OKE node pool when enable_oke_networking is false."
  type        = list(string)
  default     = []
}

variable "oke_node_quantity_per_subnet" {
  description = "Number of nodes per node subnet."
  type        = number
  default     = 1
}

variable "oke_node_image_id" {
  description = "Optional custom worker node image OCID."
  type        = string
  default     = null
}

variable "oke_ssh_public_key" {
  description = "Optional SSH public key for worker nodes."
  type        = string
  default     = null
}

variable "eks_cluster_id" {
  description = "Existing EKS cluster resource ID used as the secondary standby target."
  type        = string
  default     = null
}

variable "eks_cluster_name" {
  description = "Existing EKS cluster name used in hand-off outputs."
  type        = string
  default     = null
}

variable "eks_stack_name" {
  description = "AWS CloudFormation stack name that owns the EKS cluster."
  type        = string
  default     = null
}

variable "enable_gitops_contract" {
  description = "Publish GitOps contract metadata for Argo CD or Flux operating model."
  type        = bool
  default     = true
}

variable "gitops_tool" {
  description = "GitOps controller used for primary/standby deployment orchestration."
  type        = string
  default     = "argocd"

  validation {
    condition     = contains(["argocd", "flux"], lower(var.gitops_tool))
    error_message = "gitops_tool must be argocd or flux."
  }
}

variable "gitops_repo_url" {
  description = "GitOps repository URL used by both clusters."
  type        = string
  default     = null
}

variable "gitops_branch" {
  description = "GitOps branch used for progressive rollout."
  type        = string
  default     = "main"
}

variable "enable_traffic_steering_contract" {
  description = "Publish active/passive failover contract metadata for DNS or global traffic management."
  type        = bool
  default     = true
}

variable "app_fqdn" {
  description = "Application FQDN used for cross-cloud DNS failover decisions."
  type        = string
  default     = "app.example.com"
}

variable "oci_primary_endpoint" {
  description = "Primary endpoint for OCI-hosted ingress or gateway."
  type        = string
  default     = null
}

variable "aws_secondary_endpoint" {
  description = "Secondary endpoint for AWS-hosted ingress or gateway."
  type        = string
  default     = null
}

variable "oci_primary_traffic_percent" {
  description = "Traffic percentage directed to OCI as primary. Keep 100 for active/passive failover; use a lower value only for an intentional active/active weighted design."
  type        = number
  default     = 100

  validation {
    condition     = var.oci_primary_traffic_percent >= 0 && var.oci_primary_traffic_percent <= 100
    error_message = "oci_primary_traffic_percent must be between 0 and 100."
  }
}

variable "enable_oci_traffic_management" {
  description = "Create OCI DNS Traffic Management failover resources for the application FQDN."
  type        = bool
  default     = false
}

variable "oci_traffic_management_zone_id" {
  description = "OCI DNS zone OCID where the failover steering policy is attached."
  type        = string
  default     = null
}

variable "oci_traffic_management_domain_name" {
  description = "DNS name attached to the OCI Traffic Management steering policy. Defaults to app_fqdn."
  type        = string
  default     = null
}

variable "oci_traffic_management_record_type" {
  description = "DNS answer record type for OCI Traffic Management failover."
  type        = string
  default     = "CNAME"

  validation {
    condition     = contains(["A", "AAAA", "CNAME"], upper(var.oci_traffic_management_record_type))
    error_message = "oci_traffic_management_record_type must be A, AAAA, or CNAME."
  }
}

variable "oci_traffic_management_ttl" {
  description = "TTL in seconds for the OCI Traffic Management steering policy."
  type        = number
  default     = 30
}

variable "enable_oci_traffic_management_health_check" {
  description = "Create an OCI Health Checks HTTP monitor for Traffic Management failover."
  type        = bool
  default     = true
}

variable "oci_traffic_management_health_check_monitor_id" {
  description = "Existing OCI Health Checks monitor OCID. When set, the blueprint uses it instead of creating a monitor."
  type        = string
  default     = null
}

variable "oci_traffic_management_health_check_protocol" {
  description = "Protocol used by the OCI Health Checks monitor."
  type        = string
  default     = "HTTPS"

  validation {
    condition     = contains(["HTTP", "HTTPS"], upper(var.oci_traffic_management_health_check_protocol))
    error_message = "oci_traffic_management_health_check_protocol must be HTTP or HTTPS."
  }
}

variable "oci_traffic_management_health_check_port" {
  description = "Port used by the OCI Health Checks monitor."
  type        = number
  default     = 443
}

variable "oci_traffic_management_health_check_path" {
  description = "HTTP path used by the OCI Health Checks monitor."
  type        = string
  default     = "/"
}

variable "oci_traffic_management_health_check_interval_seconds" {
  description = "Interval in seconds for the OCI Health Checks monitor."
  type        = number
  default     = 30
}

variable "oci_traffic_management_health_check_timeout_seconds" {
  description = "Timeout in seconds for the OCI Health Checks monitor."
  type        = number
  default     = 10
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
