variable "tenancy_ocid" {
  description = "OCI tenancy OCID."
  type        = string
}

variable "compartment_ocid" {
  description = "Explicit workload compartment; no tenancy-root fallback."
  type        = string
}

variable "region" {
  description = "Selected OCI region; regional OCVS availability must be verified."
  type        = string
}

variable "org" {
  description = "Organization naming prefix."
  type        = string
}

variable "environment" {
  description = "Environment naming segment."
  type        = string
}

variable "region_key" {
  description = "Short region key."
  type        = string
}

variable "oci_config_profile" {
  description = "Only the DEFAULT OCI profile is permitted."
  type        = string
  default     = "DEFAULT"
  validation {
    condition     = var.oci_config_profile == "DEFAULT"
    error_message = "Use the DEFAULT profile for this project."
  }
}

variable "defined_tags" {
  description = "Customer defined tags."
  type        = map(string)
  default     = {}
}

variable "freeform_tags" {
  description = "Additional ownership tags."
  type        = map(string)
  default     = {}
}

variable "enable_sddc" {
  description = "Create the billed SDDC and its initial MANAGEMENT cluster."
  type        = bool
  default     = false
}

variable "inspect_existing_network" {
  description = "Read existing VCN/subnet/VLAN metadata without creating an SDDC."
  type        = bool
  default     = false
}

variable "costs_approved" {
  description = "Explicit approval for selected SDDC costs and commitment; not a price estimate."
  type        = bool
  default     = false
}

variable "sddc_display_name" {
  description = "Optional SDDC display-name override, at most 16 characters."
  type        = string
  default     = null
}

variable "cluster_display_name" {
  description = "Optional initial cluster display-name override, at most 22 characters."
  type        = string
  default     = null
}

variable "compute_availability_domain" {
  description = "Exact existing AD for the initial cluster; multi-AD is outside this blueprint scope."
  type        = string
  default     = null
}

variable "vmware_software_version" {
  description = "Supported VMware bundle for the selected region/shape; no version is guessed."
  type        = string
  default     = null
}

variable "initial_host_shape_name" {
  description = "Explicit supported BM.DenseIO shape; this blueprint uses dense/vSAN storage only."
  type        = string
  default     = null
}

variable "initial_host_ocpu_count" {
  description = "Optional supported enabled OCPU count for the chosen dense shape."
  type        = number
  default     = null
}

variable "initial_commitment" {
  description = "Explicit API-supported commitment selected after commercial review; no default purchase term."
  type        = string
  default     = null
}

variable "esxi_hosts_count" {
  description = "Initial production-cluster host count; no single-host variant."
  type        = number
  default     = 3
  validation {
    condition     = var.esxi_hosts_count >= 3 && var.esxi_hosts_count <= 64 && floor(var.esxi_hosts_count) == var.esxi_hosts_count
    error_message = "Use an integer host count between three and 64; check service limits separately."
  }
}

variable "ssh_authorized_keys" {
  description = "Public SSH key(s) only; private keys must never be supplied."
  type        = string
  default     = null
}

variable "initial_vcf_byol_allocation_id" {
  description = "Existing VMware Cloud Foundation BYOL allocation if required by the chosen offering; not created here."
  type        = string
  default     = null
}

variable "enable_hcx" {
  description = "Enable HCX in the created SDDC; separate network and licensing prerequisites apply."
  type        = bool
  default     = false
}

variable "workload_network_cidr" {
  description = "Optional NSX workload network CIDR; verify overlap with VCN/on-premises ranges separately."
  type        = string
  default     = null
  validation {
    condition     = var.workload_network_cidr == null || can(cidrnetmask(var.workload_network_cidr))
    error_message = "workload_network_cidr must be null or an IPv4 CIDR."
  }
}

variable "vcn_id" {
  description = "Existing prepared OCVS VCN."
  type        = string
  default     = null
}

variable "provisioning_subnet_id" {
  description = "Existing private ESXi provisioning subnet."
  type        = string
  default     = null
}

variable "vsphere_vlan_id" {
  description = "Existing vSphere management VLAN."
  type        = string
  default     = null
}

variable "vmotion_vlan_id" {
  description = "Existing vMotion VLAN."
  type        = string
  default     = null
}

variable "vsan_vlan_id" {
  description = "Existing vSAN VLAN."
  type        = string
  default     = null
}

variable "nsx_vtep_vlan_id" {
  description = "Existing NSX host VTEP VLAN."
  type        = string
  default     = null
}

variable "nsx_edge_vtep_vlan_id" {
  description = "Existing NSX Edge VTEP VLAN."
  type        = string
  default     = null
}

variable "nsx_edge_uplink1vlan_id" {
  description = "Existing NSX Edge uplink 1 VLAN."
  type        = string
  default     = null
}

variable "nsx_edge_uplink2vlan_id" {
  description = "Existing NSX Edge uplink 2 VLAN."
  type        = string
  default     = null
}

variable "provisioning_vlan_id" {
  description = "Existing Provisioning-Net VLAN for cold migration/cloning."
  type        = string
  default     = null
}

variable "replication_vlan_id" {
  description = "Optional existing Replication-Net VLAN; supply when the selected VMware bundle requires it."
  type        = string
  default     = null
}

variable "hcx_vlan_id" {
  description = "Existing HCX VLAN, required only when HCX is enabled."
  type        = string
  default     = null
}

variable "workload_clusters" {
  description = "Explicit initial WORKLOAD clusters; at least one is required for SDDC creation. Each reuses its own provisioning subnet and VLAN IDs inside the selected VCN. Shape, AD, bundle and commitment use the common inputs."
  type = map(object({
    display_name                   = string
    esxi_hosts_count               = optional(number, 3)
    provisioning_subnet_id         = string
    vlan_ids                       = map(string)
    workload_network_cidr          = optional(string)
    initial_vcf_byol_allocation_id = optional(string)
  }))
  default = {}
}
