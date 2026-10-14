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
run "literal_query_parameters_rejected" {
  command = plan
  variables {
    connectivity_mode               = "without-interconnect"
    oci_generative_ai_inference_url = "https://oci-adapter.example.com/inference"
    azure_openai_inference_url      = "https://azure.example.com/chat?api-version=2024-10-21"
  }
  expect_failures = [var.azure_openai_inference_url]
}
run "real_adapter_urls_preserved" {
  command = plan
  variables {
    connectivity_mode               = "without-interconnect"
    oci_generative_ai_inference_url = "https://oci-adapter.example.com/inference"
    azure_openai_inference_url      = "https://azure-adapter.example.com/inference"
  }
  assert {
    condition     = local.provider_backend_urls.azure == var.azure_openai_inference_url && local.provider_backend_urls.oci == var.oci_generative_ai_inference_url
    error_message = "Backend URLs must be preserved rather than silently truncated."
  }
}
run "placeholder_contract_cannot_be_deployed" {
  command = plan
  variables {
    connectivity_mode          = "without-interconnect"
    require_provider_endpoints = false
  }
  expect_failures = [oci_apigateway_deployment.this]
}
