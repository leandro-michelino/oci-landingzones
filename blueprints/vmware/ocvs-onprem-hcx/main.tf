# Last successful validation: 2026-10-28 | Terraform validate and 7 isolated mocked wrapper plans | oracle/oci 9.11.0.
# Scope: local schema and wrapper controls; pinned OCVS module is overridden in wrapper tests. No cloud or HCX/application test.
# Evidence: docs/VMWARE-HYBRID-20261028.md; tests/configuration-regressions.tftest.hcl.
module "ocvs" {
  source                         = "git::https://github.com/leandro-michelino/oci-landingzones.git//blueprints/industry/ocvs?ref=94ad89026bbf2ddbda531976a500e6d2ee084c7f"
  tenancy_ocid                   = var.tenancy_ocid
  compartment_ocid               = var.compartment_ocid
  region                         = var.region
  org                            = var.org
  environment                    = var.environment
  region_key                     = var.region_key
  oci_config_profile             = var.oci_config_profile
  defined_tags                   = var.defined_tags
  freeform_tags                  = var.freeform_tags
  enable_sddc                    = var.enable_sddc
  inspect_existing_network       = var.inspect_existing_network || var.enable_transport
  costs_approved                 = var.costs_approved
  sddc_display_name              = var.sddc_display_name
  cluster_display_name           = var.cluster_display_name
  compute_availability_domain    = var.compute_availability_domain
  vmware_software_version        = var.vmware_software_version
  initial_host_shape_name        = var.initial_host_shape_name
  initial_host_ocpu_count        = var.initial_host_ocpu_count
  initial_commitment             = var.initial_commitment
  esxi_hosts_count               = var.esxi_hosts_count
  ssh_authorized_keys            = var.ssh_authorized_keys
  initial_vcf_byol_allocation_id = var.initial_vcf_byol_allocation_id
  enable_hcx                     = var.enable_hcx
  workload_network_cidr          = var.workload_network_cidr
  vcn_id                         = var.vcn_id
  provisioning_subnet_id         = var.provisioning_subnet_id
  vsphere_vlan_id                = var.vsphere_vlan_id
  vmotion_vlan_id                = var.vmotion_vlan_id
  vsan_vlan_id                   = var.vsan_vlan_id
  nsx_vtep_vlan_id               = var.nsx_vtep_vlan_id
  nsx_edge_vtep_vlan_id          = var.nsx_edge_vtep_vlan_id
  nsx_edge_uplink1vlan_id        = var.nsx_edge_uplink1vlan_id
  nsx_edge_uplink2vlan_id        = var.nsx_edge_uplink2vlan_id
  provisioning_vlan_id           = var.provisioning_vlan_id
  replication_vlan_id            = var.replication_vlan_id
  hcx_vlan_id                    = var.hcx_vlan_id
  workload_clusters              = var.workload_clusters
}
resource "terraform_data" "connectivity_guard" {
  input = { transport = var.enable_transport, circuits = var.enable_circuits }
  lifecycle {
    precondition {
      condition     = !(var.enable_transport || var.enable_circuits) || var.costs_approved
      error_message = "Explicit cost approval is required for transport and partner circuits."
    }
    precondition {
      condition     = !var.enable_circuits || (var.enable_transport && var.connectivity_verified && toset(keys(var.circuits)) == toset(local.required_roles))
      error_message = "Circuits require the DRG, verified partner prerequisites and exactly the documented site-role keys."
    }
    precondition {
      condition     = alltrue([for c in values(var.circuits) : alltrue([for v in [c.provider_service_id, c.service_key, c.bandwidth] : length(trimspace(v)) > 0])])
      error_message = "Partner service, service key and bandwidth must be explicit non-empty selections."
    }
    precondition {
      condition     = !var.enable_circuits || alltrue([for role, c in var.circuits : role != "azure" || (length(c.bgp_sessions) == 2 && length(distinct([for b in c.bgp_sessions : try(cidrhost(b.customer_ip, 0), "invalid")])) == 2 && alltrue([for b in c.bgp_sessions : try(b.customer_ip == "${cidrhost(b.customer_ip, 2)}/30" && b.oracle_ip == "${cidrhost(b.customer_ip, 1)}/30", false)]))])
      error_message = "Azure circuits require two distinct /30 BGP networks, customer host 2 and Oracle host 1, as explicit reviewed inputs."
    }
    precondition {
      condition     = !var.enable_sddc || var.enable_hcx
      error_message = "These HCX topologies require enable_hcx=true when creating the OCVS SDDC."
    }
  }
}
resource "terraform_data" "migration_contract" {
  input = {
    sites         = local.required_roles
    endpoints     = var.site_endpoints
    external_work = ["On-premises vCenter/ESXi/NSX and HCX Connector", "DNS/NTP and activation/update egress", "Per-pair HCX site pairing, network/compute profiles and service meshes", "NSX routes/firewalls and existing VLAN/subnet route/security associations", "Migration waves, rollback, backup and application acceptance"]
  }
}
resource "oci_core_drg" "this" {
  count          = var.enable_transport ? 1 : 0
  compartment_id = var.compartment_ocid
  display_name   = "${local.name_prefix}-drg-vmware"
  defined_tags   = var.defined_tags
  freeform_tags  = var.freeform_tags
  depends_on     = [terraform_data.connectivity_guard]
}
resource "oci_core_drg_attachment" "ocvs" {
  count        = var.enable_transport ? 1 : 0
  drg_id       = oci_core_drg.this[0].id
  display_name = "${local.name_prefix}-drga-vmware"
  network_details {
    id   = var.vcn_id
    type = "VCN"
  }
  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags
}
resource "oci_core_virtual_circuit" "site" {
  for_each                  = var.enable_circuits && var.enable_transport ? var.circuits : {}
  compartment_id            = var.compartment_ocid
  display_name              = "${local.name_prefix}-fc-${each.key}"
  type                      = "PRIVATE"
  gateway_id                = oci_core_drg.this[0].id
  provider_service_id       = each.value.provider_service_id
  provider_service_key_name = each.value.service_key
  bandwidth_shape_name      = each.value.bandwidth
  customer_asn              = each.value.customer_asn
  ip_mtu                    = "1500"
  dynamic "cross_connect_mappings" {
    for_each = each.value.bgp_sessions
    content {
      customer_bgp_peering_ip = cross_connect_mappings.value.customer_ip
      oracle_bgp_peering_ip   = cross_connect_mappings.value.oracle_ip
    }
  }
  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags
  depends_on    = [terraform_data.connectivity_guard]
}
