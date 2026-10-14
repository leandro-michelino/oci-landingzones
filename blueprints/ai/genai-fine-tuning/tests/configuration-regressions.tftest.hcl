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
run "endpoint_uses_existing_hosting_cluster" {
  command = plan
  variables {
    create_endpoint                 = true
    model_id                        = "ocid1.generativeaimodel.oc1..example"
    hosting_dedicated_ai_cluster_id = "ocid1.generativeaidedicatedaicluster.oc1..hosting"
  }
  assert {
    condition     = oci_generative_ai_endpoint.this[0].dedicated_ai_cluster_id == var.hosting_dedicated_ai_cluster_id
    error_message = "Inference must use the explicit HOSTING cluster."
  }
}
run "fine_tuning_cluster_cannot_host_endpoint" {
  command = plan
  variables {
    create_dedicated_ai_cluster = true
    cluster_type                = "FINE_TUNING"
    create_endpoint             = true
    model_id                    = "ocid1.generativeaimodel.oc1..example"
  }
  expect_failures = [oci_generative_ai_endpoint.this]
}
run "existing_dataset_requires_namespace" {
  command = plan
  variables {
    create_fine_tuned_model = true
    dedicated_ai_cluster_id = "ocid1.generativeaidedicatedaicluster.oc1..training"
    base_model_id           = "ocid1.generativeaimodel.oc1..base"
    training_dataset_bucket = "training-documents"
  }
  expect_failures = [oci_generative_ai_model.this]
}
