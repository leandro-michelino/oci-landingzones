mock_provider "oci" {}
mock_provider "oci" { alias = "home" }

variables {
  tenancy_ocid       = "ocid1.tenancy.oc1..example"
  current_user_ocid  = "ocid1.user.oc1..example"
  compartment_ocid   = "ocid1.compartment.oc1..example"
  region             = "sa-saopaulo-1"
  home_region        = "me-abudhabi-1"
  oci_config_profile = "DEFAULT"
  org                = "test"
  environment        = "dev"
  region_key         = "sao"
}

run "no_observability_services_by_default" {
  command = plan

  assert {
    condition     = length(oci_log_analytics_namespace.this) == 0 && length(oci_apm_apm_domain.this) == 0 && length(oci_opsi_operations_insights_private_endpoint.this) == 0
    error_message = "Observability services must remain disabled by default."
  }
}

run "log_analytics_onboarding_uses_tenancy_root" {
  command = plan
  variables { enable_log_analytics_namespace = true }

  assert {
    condition     = oci_log_analytics_namespace.this[0].compartment_id == var.tenancy_ocid
    error_message = "Log Analytics namespace onboarding requires the tenancy root OCID."
  }
}
