mock_provider "oci" {}

variables {
  tenancy_ocid       = "ocid1.tenancy.oc1..example"
  current_user_ocid  = "ocid1.user.oc1..example"
  compartment_ocid   = "ocid1.compartment.oc1..example"
  region             = "sa-saopaulo-1"
  oci_config_profile = "DEFAULT"
  org                = "test"
  environment        = "dev"
  region_key         = "sao"
}

run "network_only_default_excludes_vault_and_key" {
  command = plan

  assert {
    condition     = length(module.vault.vault_ids) == 0 && length(module.vault.key_ids) == 0
    error_message = "The default telco plan must not create Vault or KMS keys."
  }

  assert {
    condition     = contains(keys(module.network.hub_subnet_ids), var.oke_endpoint_subnet_key) && contains(keys(module.network.hub_subnet_ids), var.oke_node_subnet_key)
    error_message = "Default OKE subnet keys must exist in the pinned network blueprint."
  }
}
