locals {
  blueprint_name = "industry-ocvs"
  name_prefix    = "${var.org}-${var.environment}-${var.region_key}"
  sddc_name      = coalesce(var.sddc_display_name, "${local.name_prefix}-sddc")
  cluster_name   = coalesce(var.cluster_display_name, "${local.name_prefix}-cluster")
  tags           = merge(var.freeform_tags, { ManagedBy = "Terraform", Blueprint = local.blueprint_name })
  required_vlans = {
    vsphere          = var.vsphere_vlan_id
    vmotion          = var.vmotion_vlan_id
    vsan             = var.vsan_vlan_id
    nsx_vtep         = var.nsx_vtep_vlan_id
    nsx_edge_vtep    = var.nsx_edge_vtep_vlan_id
    nsx_edge_uplink1 = var.nsx_edge_uplink1vlan_id
    nsx_edge_uplink2 = var.nsx_edge_uplink2vlan_id
    provisioning     = var.provisioning_vlan_id
  }
  management_vlans = merge(local.required_vlans,
    var.replication_vlan_id != null ? { replication = var.replication_vlan_id } : {},
    var.enable_hcx && var.hcx_vlan_id != null ? { hcx = var.hcx_vlan_id } : {}
  )
  clusters = merge({ management = {
    display_name                   = local.cluster_name
    vsphere_type                   = "MANAGEMENT"
    esxi_hosts_count               = var.esxi_hosts_count
    provisioning_subnet_id         = var.provisioning_subnet_id
    vlan_ids                       = local.management_vlans
    workload_network_cidr          = var.workload_network_cidr
    initial_vcf_byol_allocation_id = var.initial_vcf_byol_allocation_id
    } }, { for key, cluster in var.workload_clusters : "workload.${key}" => {
    display_name                   = cluster.display_name
    vsphere_type                   = "WORKLOAD"
    esxi_hosts_count               = cluster.esxi_hosts_count
    provisioning_subnet_id         = cluster.provisioning_subnet_id
    vlan_ids                       = cluster.vlan_ids
    workload_network_cidr          = cluster.workload_network_cidr
    initial_vcf_byol_allocation_id = cluster.initial_vcf_byol_allocation_id != null ? cluster.initial_vcf_byol_allocation_id : var.initial_vcf_byol_allocation_id
  } })
  vlan_ids = merge([for key, cluster in local.clusters : { for role, id in cluster.vlan_ids : "${key}.${role}" => id }]...)
  network_ids_ready = try(length(trimspace(var.vcn_id)) > 0, false) && alltrue(flatten([for cluster in values(local.clusters) : concat(
    [try(length(trimspace(cluster.provisioning_subnet_id)) > 0, false)],
    [for role in keys(local.required_vlans) : try(length(trimspace(cluster.vlan_ids[role])) > 0, false)],
    [for id in values(cluster.vlan_ids) : try(length(trimspace(id)) > 0, false)]
  )]))
  inspect              = (var.enable_sddc || var.inspect_existing_network) && local.network_ids_ready
  cluster_inputs_ready = alltrue([for value in [var.compute_availability_domain, var.vmware_software_version, var.initial_commitment] : try(length(trimspace(value)) > 0, false)]) && var.compute_availability_domain != "multi-AD" && can(regex("^BM\\.DenseIO", var.initial_host_shape_name)) && can(regex("(?m)^ssh-rsa [A-Za-z0-9+/=]+", var.ssh_authorized_keys))
}
