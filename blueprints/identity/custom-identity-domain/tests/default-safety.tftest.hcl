mock_provider "oci" {}

variables {
  tenancy_ocid      = "ocid1.tenancy.oc1..example"
  current_user_ocid = "ocid1.user.oc1..example"
  compartment_ocid  = "ocid1.compartment.oc1..example"
  region            = "sa-saopaulo-1"
  home_region       = "me-abudhabi-1"
  org               = "test"
  environment       = "dev"
  region_key        = "sao"
}

run "no_identity_domain_by_default" {
  command = plan

  assert {
    condition     = length(oci_identity_domain.this) == 0 && length(oci_identity_domain_replication_to_region.replicas) == 0
    error_message = "Custom identity domains must be explicitly configured."
  }
}

run "explicit_domain_stays_in_selected_compartment" {
  command = plan
  variables {
    identity_domains = {
      workforce = { description = "Isolated workforce test contract." }
    }
  }

  assert {
    condition     = oci_identity_domain.this["workforce"].compartment_id == var.compartment_ocid && oci_identity_domain.this["workforce"].home_region == var.home_region && length(oci_identity_domain_replication_to_region.replicas) == 0
    error_message = "An explicit domain must use the selected compartment and home region without replicas."
  }
}
