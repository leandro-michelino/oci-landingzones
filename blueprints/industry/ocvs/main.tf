# Last successful validation: 2026-10-28 | Terraform validate and 19 mocked plans | oracle/oci 9.11.0.
# Scope: local schema/configuration only; no SDDC provisioning, management access, migration or live cleanup test.
# Evidence: docs/OCVS-20261028.md; tests/configuration-regressions.tftest.hcl.
data "oci_core_vcn" "existing" {
  count  = local.inspect ? 1 : 0
  vcn_id = var.vcn_id
}
data "oci_core_subnet" "provisioning" {
  for_each  = local.inspect ? local.clusters : {}
  subnet_id = each.value.provisioning_subnet_id
}
data "oci_core_vlan" "existing" {
  for_each = local.inspect ? local.vlan_ids : {}
  vlan_id  = each.value
}
resource "terraform_data" "guard" {
  input = { enable_sddc = var.enable_sddc, inspect_existing_network = var.inspect_existing_network }
  lifecycle {
    precondition {
      condition     = !var.enable_sddc || var.costs_approved
      error_message = "Creating an SDDC requires explicit approval of the selected billed resources and commitment."
    }
    precondition {
      condition     = !(var.enable_sddc || var.inspect_existing_network) || local.network_ids_ready
      error_message = "Supply the existing VCN and a private provisioning subnet plus eight baseline VLAN roles for every configured cluster."
    }
    precondition {
      condition     = !(var.enable_sddc || var.inspect_existing_network) || (length(distinct(values(local.vlan_ids))) == length(local.vlan_ids) && length(distinct([for c in values(local.clusters) : c.provisioning_subnet_id])) == length(local.clusters))
      error_message = "Every cluster needs its own provisioning subnet and every VLAN role must use a globally distinct VLAN ID."
    }
    precondition {
      condition     = !var.enable_sddc || local.cluster_inputs_ready
      error_message = "Supply a single AD, supported VMware bundle, explicit commitment, BM.DenseIO shape and RSA public SSH key. Standard/block-storage shapes are outside this blueprint."
    }
    precondition {
      condition = !var.enable_sddc || (
        can(regex("^[A-Za-z][A-Za-z0-9-]{0,15}$", local.sddc_name)) && !strcontains(local.sddc_name, "--") &&
        alltrue([for c in values(local.clusters) : can(regex("^[A-Za-z][A-Za-z0-9-]{0,21}$", c.display_name)) && !strcontains(c.display_name, "--")]) &&
        length(distinct([for c in values(local.clusters) : c.display_name])) == length(local.clusters)
      )
      error_message = "Use a 1-16 character SDDC name and distinct 1-22 character cluster names, starting with a letter and without repeated hyphens."
    }
    precondition {
      condition     = !var.enable_sddc || (length(var.workload_clusters) >= 1 && alltrue([for c in values(var.workload_clusters) : c.esxi_hosts_count >= 3 && c.esxi_hosts_count <= 64 && floor(c.esxi_hosts_count) == c.esxi_hosts_count]))
      error_message = "Supply at least one initial WORKLOAD cluster with an integer host count of 3-64; the MANAGEMENT cluster is configured separately."
    }
    precondition {
      condition     = alltrue([for c in values(local.clusters) : c.workload_network_cidr == null || can(cidrnetmask(c.workload_network_cidr))]) && alltrue([for c in values(var.workload_clusters) : length(setsubtract(toset(keys(c.vlan_ids)), setunion(toset(keys(local.required_vlans)), toset(["replication"])))) == 0])
      error_message = "Cluster workload CIDRs must be IPv4 or null; WORKLOAD VLAN maps accept the eight baseline roles plus optional replication, with HCX restricted to MANAGEMENT."
    }

    precondition {
      condition     = !var.enable_sddc || !var.enable_hcx || try(length(trimspace(var.hcx_vlan_id)) > 0, false)
      error_message = "HCX requires its existing dedicated VLAN; licensing, vSphere NAT routing and remote HCX configuration remain prerequisites."
    }
    precondition {
      condition     = alltrue([for vcn in data.oci_core_vcn.existing : vcn.compartment_id == var.compartment_ocid]) && alltrue([for subnet in data.oci_core_subnet.provisioning : subnet.vcn_id == var.vcn_id && subnet.compartment_id == var.compartment_ocid && subnet.prohibit_public_ip_on_vnic]) && alltrue([for vlan in data.oci_core_vlan.existing : vlan.vcn_id == var.vcn_id && vlan.compartment_id == var.compartment_ocid])
      error_message = "VCN/subnet/VLANs must stay in the selected compartment and VCN, and the provisioning subnet must prohibit public IPs."
    }
    precondition {
      condition = !var.enable_sddc || (
        alltrue([for sn in data.oci_core_subnet.provisioning : sn.availability_domain == null || sn.availability_domain == "" || sn.availability_domain == var.compute_availability_domain]) &&
        alltrue([for vlan in data.oci_core_vlan.existing : vlan.availability_domain == null || vlan.availability_domain == "" || vlan.availability_domain == var.compute_availability_domain])
      )
      error_message = "AD-specific provisioning subnet and VLANs must match the initial cluster AD; regional resources are allowed."
    }
  }
}
resource "oci_ocvp_sddc" "this" {
  count                   = var.enable_sddc && local.network_ids_ready && local.cluster_inputs_ready && length(var.workload_clusters) > 0 ? 1 : 0
  compartment_id          = var.compartment_ocid
  display_name            = local.sddc_name
  vmware_software_version = var.vmware_software_version
  ssh_authorized_keys     = var.ssh_authorized_keys
  is_single_host_sddc     = false
  is_hcx_enabled          = var.enable_hcx
  defined_tags            = var.defined_tags
  freeform_tags           = local.tags
  initial_configuration {
    dynamic "initial_cluster_configurations" {
      for_each = local.clusters
      content {
        vsphere_type                   = initial_cluster_configurations.value.vsphere_type
        display_name                   = initial_cluster_configurations.value.display_name
        compute_availability_domain    = var.compute_availability_domain
        esxi_hosts_count               = initial_cluster_configurations.value.esxi_hosts_count
        initial_host_shape_name        = var.initial_host_shape_name
        initial_host_ocpu_count        = var.initial_host_ocpu_count
        initial_commitment             = var.initial_commitment
        initial_vcf_byol_allocation_id = initial_cluster_configurations.value.initial_vcf_byol_allocation_id
        workload_network_cidr          = initial_cluster_configurations.value.workload_network_cidr
        network_configuration {
          provisioning_subnet_id  = initial_cluster_configurations.value.provisioning_subnet_id
          vsphere_vlan_id         = lookup(initial_cluster_configurations.value.vlan_ids, "vsphere", null)
          vmotion_vlan_id         = lookup(initial_cluster_configurations.value.vlan_ids, "vmotion", null)
          vsan_vlan_id            = lookup(initial_cluster_configurations.value.vlan_ids, "vsan", null)
          nsx_vtep_vlan_id        = lookup(initial_cluster_configurations.value.vlan_ids, "nsx_vtep", null)
          nsx_edge_vtep_vlan_id   = lookup(initial_cluster_configurations.value.vlan_ids, "nsx_edge_vtep", null)
          nsx_edge_uplink1vlan_id = lookup(initial_cluster_configurations.value.vlan_ids, "nsx_edge_uplink1", null)
          nsx_edge_uplink2vlan_id = lookup(initial_cluster_configurations.value.vlan_ids, "nsx_edge_uplink2", null)
          provisioning_vlan_id    = lookup(initial_cluster_configurations.value.vlan_ids, "provisioning", null)
          replication_vlan_id     = lookup(initial_cluster_configurations.value.vlan_ids, "replication", null)
          hcx_vlan_id             = initial_cluster_configurations.value.vsphere_type == "MANAGEMENT" && var.enable_hcx ? var.hcx_vlan_id : null
        }
      }
    }
  }
  depends_on = [terraform_data.guard]
}
