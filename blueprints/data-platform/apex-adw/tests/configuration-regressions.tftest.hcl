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
run "disabled_without_database_or_urls" {
  command = plan
  assert {
    condition     = output.apex_direct_url == null && output.ords_direct_url == null && length(oci_load_balancer_load_balancer.this) == 0
    error_message = "The disabled APEX integration must allow absent database and URL inputs."
  }
}
run "secret_creation_count_is_not_sensitive" {
  command = plan
  variables {
    enable_admin_secret         = true
    vault_id                    = "ocid1.vault.oc1..example"
    key_id                      = "ocid1.key.oc1..example"
    admin_secret_content_base64 = base64encode("mock-material")
  }
  assert {
    condition     = length(oci_vault_secret.apex_admin) == 1
    error_message = "An explicit creation flag must control secret count independently of sensitive content."
  }
}
run "existing_secret_reused_without_creation" {
  command = plan
  variables { admin_secret_id = "mock-secret" }
  assert {
    condition     = length(oci_vault_secret.apex_admin) == 0 && output.admin_secret_id == var.admin_secret_id
    error_message = "An existing secret must remain an external reference."
  }
}
run "existing_secret_cannot_enable_creation" {
  command = plan
  variables {
    enable_admin_secret = true
    admin_secret_id     = "mock-secret"
  }
  expect_failures = [var.enable_admin_secret]
}
