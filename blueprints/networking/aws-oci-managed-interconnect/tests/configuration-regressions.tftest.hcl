mock_provider "oci" {}
mock_provider "aws" {}
variables {
  tenancy_ocid     = "ocid1.tenancy.oc1..example"
  compartment_ocid = "ocid1.compartment.oc1..example"
  region           = "sa-saopaulo-1"
  org              = "example"
  environment      = "dev"
  region_key       = "gru"
  aws_region       = "us-east-1"
  aws_account_id   = "123456789012"
  aws_az           = "us-east-1a"
}
run "disabled_defaults" {
  command = plan
  assert {
    condition     = length(oci_core_vcn.this) == 0 && length(aws_vpc.this) == 0 && length(oci_core_virtual_circuit.this) == 0
    error_message = "Disabled defaults must not create cloud resources."
  }
}
run "foundation_with_scoped_access" {
  command = plan
  variables {
    costs_approved    = true
    enable_foundation = true
    allowed_tcp_ports = [443]
  }
  assert {
    condition     = oci_core_subnet.this[0].prohibit_public_ip_on_vnic && length(oci_core_virtual_circuit.this) == 0
    error_message = "Foundation must remain private with circuits disabled."
  }
  assert {
    condition     = length(aws_vpc_security_group_ingress_rule.this) == 1 && aws_route.oci[0].destination_cidr_block == var.oci_subnet_cidr
    error_message = "Remote foundation must retain explicit access and routing controls."
  }
}
run "circuit_requires_cost_approval" {
  command = plan
  variables {
    enable_foundation   = true
    enable_interconnect = true
  }
  expect_failures = [terraform_data.guard]
}
run "overlapping_ranges_rejected" {
  command = plan
  variables { remote_subnet_cidr = "10.56.20.0/24" }
  expect_failures = [terraform_data.guard]
}
run "invalid_ports_rejected" {
  command = plan
  variables { allowed_tcp_ports = [0, 65536] }
  expect_failures = [terraform_data.guard]
}
run "subnet_outside_vcn_rejected" {
  command = plan
  variables { oci_subnet_cidr = "192.168.5.0/24" }
  expect_failures = [terraform_data.guard]
}
run "approved_circuit_configuration" {
  command = plan
  variables {
    region_pair_verified = true
    enable_foundation    = true
    enable_interconnect  = true
    costs_approved       = true
    provider_service_id  = "ocid1.providerservice.oc1..verified-example"
  }
  assert {
    condition     = length(oci_core_virtual_circuit.this) == 1 && oci_core_virtual_circuit.this[0].remote_account_id == var.aws_account_id && oci_core_virtual_circuit.this[0].provider_remote_region == var.aws_region
    error_message = "Approved circuit topology must include the correct remote pairing configuration."
  }
}
run "foundation_requires_cost_approval" {
  command = plan
  variables { enable_foundation = true }
  expect_failures = [terraform_data.guard]
}
run "region_pair_must_be_verified" {
  command = plan
  variables {
    enable_foundation   = true
    enable_interconnect = true
    costs_approved      = true
    provider_service_id = "ocid1.providerservice.oc1..verified-example"
  }
  expect_failures = [terraform_data.guard]
}
