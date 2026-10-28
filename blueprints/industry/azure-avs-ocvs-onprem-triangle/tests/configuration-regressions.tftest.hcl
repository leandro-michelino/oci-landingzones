mock_provider "oci" {}
override_module {
  target = module.ocvs
  outputs = {
    resource_ids         = { sddc = null }
    management_endpoints = {}
    network_references   = {}
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
  enable_transport               = false
  enable_circuits                = false
  connectivity_verified          = false
  circuits                       = {}
  site_endpoints                 = {}
}
run "disabled_no_transport" {
  command = plan
  assert {
    condition     = length(oci_core_drg.this) == 0 && length(oci_core_virtual_circuit.site) == 0 && module.ocvs.resource_ids.sddc == null
    error_message = "Disabled defaults must not create cloud resources."
  }
}
run "transport_cost_guard" {
  command = plan
  variables {
    enable_transport = true
  }
  expect_failures = [terraform_data.connectivity_guard]
}
run "approved_transport_on_existing_network" {
  command = plan
  variables {
    enable_transport = true
    costs_approved   = true
  }
  assert {
    condition     = length(oci_core_drg.this) == 1 && length(oci_core_drg_attachment.ocvs) == 1 && length(oci_core_virtual_circuit.site) == 0
    error_message = "Foundation must create a DRG/attachment only."
  }
}
run "circuits_require_transport_and_verification" {
  command = plan
  variables {
    enable_circuits = true
    costs_approved  = true
  }
  expect_failures = [terraform_data.connectivity_guard]
}
run "wrong_site_roles_rejected" {
  command = plan
  variables {
    enable_transport      = true
    enable_circuits       = true
    connectivity_verified = true
    costs_approved        = true
    circuits              = { wrong = { provider_service_id = "provider", service_key = "mock-key", bandwidth = "1 Gbps" } }
  }
  expect_failures = [terraform_data.connectivity_guard]
}
run "approved_partner_circuits" {
  command = plan
  variables {
    enable_transport      = true
    enable_circuits       = true
    connectivity_verified = true
    costs_approved        = true
    circuits              = { azure = { provider_service_id = "mock-provider-azure", service_key = "mock-key-azure", bandwidth = "1 Gbps", bgp_sessions = [{ customer_ip = "10.254.0.2/30", oracle_ip = "10.254.0.1/30" }, { customer_ip = "10.254.0.6/30", oracle_ip = "10.254.0.5/30" }] }, onprem = { provider_service_id = "mock-provider-onprem", service_key = "mock-key-onprem", bandwidth = "1 Gbps" } }
  }
  assert {
    condition     = length(oci_core_virtual_circuit.site) == 2
    error_message = "One declared partner VC instance per required site role."
  }
}
run "sddc_requires_hcx" {
  command = plan
  variables {
    enable_sddc    = true
    costs_approved = true
  }
  expect_failures = [terraform_data.connectivity_guard]
}
run "azure_bgp_pairs_required" {
  command = plan
  variables {
    enable_transport      = true
    enable_circuits       = true
    costs_approved        = true
    connectivity_verified = true
    circuits              = { azure = { provider_service_id = "provider", service_key = "mock", bandwidth = "1 Gbps" }, onprem = { provider_service_id = "provider", service_key = "mock", bandwidth = "1 Gbps" } }
  }
  expect_failures = [terraform_data.connectivity_guard]
}
run "azure_bgp_networks_must_differ" {
  command = plan
  variables {
    enable_transport      = true
    enable_circuits       = true
    costs_approved        = true
    connectivity_verified = true
    circuits              = { azure = { provider_service_id = "provider", service_key = "mock", bandwidth = "1 Gbps", bgp_sessions = [{ customer_ip = "10.254.0.2/30", oracle_ip = "10.254.0.1/30" }, { customer_ip = "10.254.0.2/30", oracle_ip = "10.254.0.1/30" }] }, onprem = { provider_service_id = "provider", service_key = "mock", bandwidth = "1 Gbps" } }
  }
  expect_failures = [terraform_data.connectivity_guard]
}
