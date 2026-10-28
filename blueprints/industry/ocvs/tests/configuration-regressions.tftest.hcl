mock_provider "oci" {
  mock_data "oci_core_vcn" {
    defaults = { compartment_id = "ocid1.compartment.oc1..example" }
  }
  mock_data "oci_core_subnet" {
    defaults = { vcn_id = "ocid1.vcn.oc1..example", compartment_id = "ocid1.compartment.oc1..example", prohibit_public_ip_on_vnic = true, availability_domain = "TEST-AD-1" }
  }
  mock_data "oci_core_vlan" {
    defaults = { vcn_id = "ocid1.vcn.oc1..example", compartment_id = "ocid1.compartment.oc1..example", availability_domain = "TEST-AD-1" }
  }
}
variables {
  vsphere_vlan_id                = "ocid1.vlan.oc1..vsphere_vlan_id"
  vmotion_vlan_id                = "ocid1.vlan.oc1..vmotion_vlan_id"
  vsan_vlan_id                   = "ocid1.vlan.oc1..vsan_vlan_id"
  nsx_vtep_vlan_id               = "ocid1.vlan.oc1..nsx_vtep_vlan_id"
  nsx_edge_vtep_vlan_id          = "ocid1.vlan.oc1..nsx_edge_vtep_vlan_id"
  nsx_edge_uplink1vlan_id        = "ocid1.vlan.oc1..nsx_edge_uplink1vlan_id"
  nsx_edge_uplink2vlan_id        = "ocid1.vlan.oc1..nsx_edge_uplink2vlan_id"
  provisioning_vlan_id           = "ocid1.vlan.oc1..provisioning_vlan_id"
  tenancy_ocid                   = "ocid1.tenancy.oc1..example"
  compartment_ocid               = "ocid1.compartment.oc1..example"
  region                         = "sa-saopaulo-1"
  oci_config_profile             = "DEFAULT"
  org                            = "abc"
  environment                    = "test"
  region_key                     = "gru"
  vcn_id                         = "ocid1.vcn.oc1..example"
  provisioning_subnet_id         = "ocid1.subnet.oc1..example"
  compute_availability_domain    = "TEST-AD-1"
  vmware_software_version        = "MOCK-BUNDLE"
  initial_host_shape_name        = "BM.DenseIO.MOCK"
  initial_commitment             = "MOCK-TERM"
  ssh_authorized_keys            = "ssh-rsa AAAATESTPUBLICKEY"
  initial_vcf_byol_allocation_id = null
  workload_network_cidr          = null
  initial_host_ocpu_count        = null
  replication_vlan_id            = null
  hcx_vlan_id                    = null
  sddc_display_name              = "abc-test-gru"
  cluster_display_name           = "abc-test-gru-cluster"
  enable_sddc                    = false
  inspect_existing_network       = false
  costs_approved                 = false
  enable_hcx                     = false
  esxi_hosts_count               = 3
  defined_tags                   = {}
  freeform_tags                  = {}
  workload_clusters              = {}
}
run "disabled_no_cloud_or_lookups" {
  command = plan
  assert {
    condition     = length(oci_ocvp_sddc.this) == 0 && length(data.oci_core_vcn.existing) == 0 && length(data.oci_core_subnet.provisioning) == 0 && length(data.oci_core_vlan.existing) == 0
    error_message = "OCVS configuration regression: disabled_no_cloud_or_lookups."
  }
}
run "read_only_network_inspection" {
  command = plan
  variables {
    inspect_existing_network = true
  }
  assert {
    condition     = length(oci_ocvp_sddc.this) == 0 && length(data.oci_core_vlan.existing) == 8
    error_message = "OCVS configuration regression: read_only_network_inspection."
  }
}
run "cost_approval_required" {
  command = plan
  variables {
    enable_sddc       = true
    workload_clusters = { "apps" : { "display_name" : "abc-test-gru-apps", "esxi_hosts_count" : 3, "provisioning_subnet_id" : "ocid1.subnet.oc1..apps", "vlan_ids" : { "vsphere" : "ocid1.vlan.oc1..apps-vsphere", "vmotion" : "ocid1.vlan.oc1..apps-vmotion", "vsan" : "ocid1.vlan.oc1..apps-vsan", "nsx_vtep" : "ocid1.vlan.oc1..apps-nsx_vtep", "nsx_edge_vtep" : "ocid1.vlan.oc1..apps-nsx_edge_vtep", "nsx_edge_uplink1" : "ocid1.vlan.oc1..apps-nsx_edge_uplink1", "nsx_edge_uplink2" : "ocid1.vlan.oc1..apps-nsx_edge_uplink2", "provisioning" : "ocid1.vlan.oc1..apps-provisioning" } } }
  }
  expect_failures = [terraform_data.guard]
}
run "missing_network_rejected" {
  command = plan
  variables {
    inspect_existing_network = true
    vsan_vlan_id             = null
  }
  expect_failures = [terraform_data.guard]
}
run "duplicate_vlan_rejected" {
  command = plan
  variables {
    inspect_existing_network = true
    vmotion_vlan_id          = "ocid1.vlan.oc1..vsan_vlan_id"
  }
  expect_failures = [terraform_data.guard]
}
run "hcx_requires_dedicated_vlan" {
  command = plan
  variables {
    enable_sddc       = true
    workload_clusters = { "apps" : { "display_name" : "abc-test-gru-apps", "esxi_hosts_count" : 3, "provisioning_subnet_id" : "ocid1.subnet.oc1..apps", "vlan_ids" : { "vsphere" : "ocid1.vlan.oc1..apps-vsphere", "vmotion" : "ocid1.vlan.oc1..apps-vmotion", "vsan" : "ocid1.vlan.oc1..apps-vsan", "nsx_vtep" : "ocid1.vlan.oc1..apps-nsx_vtep", "nsx_edge_vtep" : "ocid1.vlan.oc1..apps-nsx_edge_vtep", "nsx_edge_uplink1" : "ocid1.vlan.oc1..apps-nsx_edge_uplink1", "nsx_edge_uplink2" : "ocid1.vlan.oc1..apps-nsx_edge_uplink2", "provisioning" : "ocid1.vlan.oc1..apps-provisioning" } } }
    costs_approved    = true
    enable_hcx        = true
  }
  expect_failures = [terraform_data.guard]
}
run "standard_shape_rejected" {
  command = plan
  variables {
    enable_sddc             = true
    workload_clusters       = { "apps" : { "display_name" : "abc-test-gru-apps", "esxi_hosts_count" : 3, "provisioning_subnet_id" : "ocid1.subnet.oc1..apps", "vlan_ids" : { "vsphere" : "ocid1.vlan.oc1..apps-vsphere", "vmotion" : "ocid1.vlan.oc1..apps-vmotion", "vsan" : "ocid1.vlan.oc1..apps-vsan", "nsx_vtep" : "ocid1.vlan.oc1..apps-nsx_vtep", "nsx_edge_vtep" : "ocid1.vlan.oc1..apps-nsx_edge_vtep", "nsx_edge_uplink1" : "ocid1.vlan.oc1..apps-nsx_edge_uplink1", "nsx_edge_uplink2" : "ocid1.vlan.oc1..apps-nsx_edge_uplink2", "provisioning" : "ocid1.vlan.oc1..apps-provisioning" } } }
    costs_approved          = true
    initial_host_shape_name = "BM.Standard.MOCK"
  }
  expect_failures = [terraform_data.guard]
}
run "undersized_cluster_rejected" {
  command = plan
  variables {
    esxi_hosts_count = 1
  }
  expect_failures = [var.esxi_hosts_count]
}
run "name_limit_rejected" {
  command = plan
  variables {
    enable_sddc       = true
    workload_clusters = { "apps" : { "display_name" : "abc-test-gru-apps", "esxi_hosts_count" : 3, "provisioning_subnet_id" : "ocid1.subnet.oc1..apps", "vlan_ids" : { "vsphere" : "ocid1.vlan.oc1..apps-vsphere", "vmotion" : "ocid1.vlan.oc1..apps-vmotion", "vsan" : "ocid1.vlan.oc1..apps-vsan", "nsx_vtep" : "ocid1.vlan.oc1..apps-nsx_vtep", "nsx_edge_vtep" : "ocid1.vlan.oc1..apps-nsx_edge_vtep", "nsx_edge_uplink1" : "ocid1.vlan.oc1..apps-nsx_edge_uplink1", "nsx_edge_uplink2" : "ocid1.vlan.oc1..apps-nsx_edge_uplink2", "provisioning" : "ocid1.vlan.oc1..apps-provisioning" } } }
    costs_approved    = true
    sddc_display_name = "this-name-is-much-too-long"
  }
  expect_failures = [terraform_data.guard]
}
run "wrong_compartment_rejected" {
  command = plan
  variables {
    inspect_existing_network = true
  }
  override_data {
    target = data.oci_core_vcn.existing[0]
    values = { compartment_id = "ocid1.compartment.oc1..wrong" }
  }
  expect_failures = [terraform_data.guard]
}
run "public_provisioning_subnet_rejected" {
  command = plan
  variables {
    inspect_existing_network = true
  }
  override_data {
    target = data.oci_core_subnet.provisioning["management"]
    values = { vcn_id = "ocid1.vcn.oc1..example", compartment_id = "ocid1.compartment.oc1..example", prohibit_public_ip_on_vnic = false }
  }
  expect_failures = [terraform_data.guard]
}
run "wrong_vcn_rejected" {
  command = plan
  variables {
    inspect_existing_network = true
  }
  override_data {
    target = data.oci_core_vlan.existing["management.vsan"]
    values = { vcn_id = "ocid1.vcn.oc1..wrong", compartment_id = "ocid1.compartment.oc1..example" }
  }
  expect_failures = [terraform_data.guard]
}
run "wrong_ad_rejected" {
  command = plan
  variables {
    enable_sddc       = true
    workload_clusters = { "apps" : { "display_name" : "abc-test-gru-apps", "esxi_hosts_count" : 3, "provisioning_subnet_id" : "ocid1.subnet.oc1..apps", "vlan_ids" : { "vsphere" : "ocid1.vlan.oc1..apps-vsphere", "vmotion" : "ocid1.vlan.oc1..apps-vmotion", "vsan" : "ocid1.vlan.oc1..apps-vsan", "nsx_vtep" : "ocid1.vlan.oc1..apps-nsx_vtep", "nsx_edge_vtep" : "ocid1.vlan.oc1..apps-nsx_edge_vtep", "nsx_edge_uplink1" : "ocid1.vlan.oc1..apps-nsx_edge_uplink1", "nsx_edge_uplink2" : "ocid1.vlan.oc1..apps-nsx_edge_uplink2", "provisioning" : "ocid1.vlan.oc1..apps-provisioning" } } }
    costs_approved    = true
  }
  override_data {
    target = data.oci_core_vlan.existing["management.vsan"]
    values = { vcn_id = "ocid1.vcn.oc1..example", compartment_id = "ocid1.compartment.oc1..example", availability_domain = "TEST-AD-2" }
  }
  expect_failures = [terraform_data.guard]
}
run "configured_management_cluster" {
  command = plan
  variables {
    enable_sddc       = true
    workload_clusters = { "apps" : { "display_name" : "abc-test-gru-apps", "esxi_hosts_count" : 3, "provisioning_subnet_id" : "ocid1.subnet.oc1..apps", "vlan_ids" : { "vsphere" : "ocid1.vlan.oc1..apps-vsphere", "vmotion" : "ocid1.vlan.oc1..apps-vmotion", "vsan" : "ocid1.vlan.oc1..apps-vsan", "nsx_vtep" : "ocid1.vlan.oc1..apps-nsx_vtep", "nsx_edge_vtep" : "ocid1.vlan.oc1..apps-nsx_edge_vtep", "nsx_edge_uplink1" : "ocid1.vlan.oc1..apps-nsx_edge_uplink1", "nsx_edge_uplink2" : "ocid1.vlan.oc1..apps-nsx_edge_uplink2", "provisioning" : "ocid1.vlan.oc1..apps-provisioning" } } }
    costs_approved    = true
  }
  assert {
    condition     = length(oci_ocvp_sddc.this) == 1 && !oci_ocvp_sddc.this[0].is_single_host_sddc && !oci_ocvp_sddc.this[0].is_hcx_enabled && length(one(oci_ocvp_sddc.this[0].initial_configuration).initial_cluster_configurations) == 2 && one([for c in one(oci_ocvp_sddc.this[0].initial_configuration).initial_cluster_configurations : c if c.vsphere_type == "MANAGEMENT"]).vsphere_type == "MANAGEMENT" && one([for c in one(oci_ocvp_sddc.this[0].initial_configuration).initial_cluster_configurations : c if c.vsphere_type == "MANAGEMENT"]).esxi_hosts_count == 3 && one(one([for c in one(oci_ocvp_sddc.this[0].initial_configuration).initial_cluster_configurations : c if c.vsphere_type == "WORKLOAD"]).network_configuration).provisioning_subnet_id == "ocid1.subnet.oc1..apps"
    error_message = "OCVS configuration regression: configured_management_cluster."
  }
}
run "configured_hcx_and_byol_reference" {
  command = plan
  variables {
    enable_sddc                    = true
    workload_clusters              = { "apps" : { "display_name" : "abc-test-gru-apps", "esxi_hosts_count" : 3, "provisioning_subnet_id" : "ocid1.subnet.oc1..apps", "vlan_ids" : { "vsphere" : "ocid1.vlan.oc1..apps-vsphere", "vmotion" : "ocid1.vlan.oc1..apps-vmotion", "vsan" : "ocid1.vlan.oc1..apps-vsan", "nsx_vtep" : "ocid1.vlan.oc1..apps-nsx_vtep", "nsx_edge_vtep" : "ocid1.vlan.oc1..apps-nsx_edge_vtep", "nsx_edge_uplink1" : "ocid1.vlan.oc1..apps-nsx_edge_uplink1", "nsx_edge_uplink2" : "ocid1.vlan.oc1..apps-nsx_edge_uplink2", "provisioning" : "ocid1.vlan.oc1..apps-provisioning" } } }
    costs_approved                 = true
    enable_hcx                     = true
    hcx_vlan_id                    = "ocid1.vlan.oc1..hcx"
    initial_vcf_byol_allocation_id = "ocid1.byolallocation.oc1..example"
  }
  assert {
    condition     = length(data.oci_core_vlan.existing) == 17 && oci_ocvp_sddc.this[0].is_hcx_enabled && one(one([for c in one(oci_ocvp_sddc.this[0].initial_configuration).initial_cluster_configurations : c if c.vsphere_type == "MANAGEMENT"]).network_configuration).hcx_vlan_id == "ocid1.vlan.oc1..hcx" && one([for c in one(oci_ocvp_sddc.this[0].initial_configuration).initial_cluster_configurations : c if c.vsphere_type == "MANAGEMENT"]).initial_vcf_byol_allocation_id == "ocid1.byolallocation.oc1..example"
    error_message = "OCVS configuration regression: configured_hcx_and_byol_reference."
  }
}

run "missing_deployment_inputs_rejected" {
  command = plan
  variables {
    enable_sddc             = true
    workload_clusters       = { "apps" : { "display_name" : "abc-test-gru-apps", "esxi_hosts_count" : 3, "provisioning_subnet_id" : "ocid1.subnet.oc1..apps", "vlan_ids" : { "vsphere" : "ocid1.vlan.oc1..apps-vsphere", "vmotion" : "ocid1.vlan.oc1..apps-vmotion", "vsan" : "ocid1.vlan.oc1..apps-vsan", "nsx_vtep" : "ocid1.vlan.oc1..apps-nsx_vtep", "nsx_edge_vtep" : "ocid1.vlan.oc1..apps-nsx_edge_vtep", "nsx_edge_uplink1" : "ocid1.vlan.oc1..apps-nsx_edge_uplink1", "nsx_edge_uplink2" : "ocid1.vlan.oc1..apps-nsx_edge_uplink2", "provisioning" : "ocid1.vlan.oc1..apps-provisioning" } } }
    costs_approved          = true
    vmware_software_version = null
    initial_commitment      = null
    ssh_authorized_keys     = null
  }
  expect_failures = [terraform_data.guard]
}

run "workload_cluster_required" {
  command = plan
  variables {
    enable_sddc       = true
    costs_approved    = true
    workload_clusters = {}
  }
  expect_failures = [terraform_data.guard]
}
run "shared_subnet_rejected" {
  command = plan
  variables {
    enable_sddc       = true
    costs_approved    = true
    workload_clusters = { "apps" : { "display_name" : "abc-test-gru-apps", "esxi_hosts_count" : 3, "provisioning_subnet_id" : "ocid1.subnet.oc1..example", "vlan_ids" : { "vsphere" : "ocid1.vlan.oc1..apps-vsphere", "vmotion" : "ocid1.vlan.oc1..apps-vmotion", "vsan" : "ocid1.vlan.oc1..apps-vsan", "nsx_vtep" : "ocid1.vlan.oc1..apps-nsx_vtep", "nsx_edge_vtep" : "ocid1.vlan.oc1..apps-nsx_edge_vtep", "nsx_edge_uplink1" : "ocid1.vlan.oc1..apps-nsx_edge_uplink1", "nsx_edge_uplink2" : "ocid1.vlan.oc1..apps-nsx_edge_uplink2", "provisioning" : "ocid1.vlan.oc1..apps-provisioning" } } }
  }
  expect_failures = [terraform_data.guard]
}
run "cross_cluster_vlan_reuse_rejected" {
  command = plan
  variables {
    enable_sddc       = true
    costs_approved    = true
    workload_clusters = { "apps" : { "display_name" : "abc-test-gru-apps", "esxi_hosts_count" : 3, "provisioning_subnet_id" : "ocid1.subnet.oc1..apps", "vlan_ids" : { "vsphere" : "ocid1.vlan.oc1..apps-vsphere", "vmotion" : "ocid1.vlan.oc1..apps-vmotion", "vsan" : "ocid1.vlan.oc1..vsan_vlan_id", "nsx_vtep" : "ocid1.vlan.oc1..apps-nsx_vtep", "nsx_edge_vtep" : "ocid1.vlan.oc1..apps-nsx_edge_vtep", "nsx_edge_uplink1" : "ocid1.vlan.oc1..apps-nsx_edge_uplink1", "nsx_edge_uplink2" : "ocid1.vlan.oc1..apps-nsx_edge_uplink2", "provisioning" : "ocid1.vlan.oc1..apps-provisioning" } } }
  }
  expect_failures = [terraform_data.guard]
}
