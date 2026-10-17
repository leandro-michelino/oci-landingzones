mock_provider "oci" {}
mock_provider "oci" { alias = "home" }

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

run "no_function_by_default" {
  command = plan

  assert {
    condition     = length(oci_functions_function.this) == 0 && length(oci_functions_application.this) == 0
    error_message = "Functions and its application must remain disabled by default."
  }
}

run "container_image_uses_source_details" {
  command = plan
  variables {
    enable_functions = true
    application_id   = "ocid1.fnapp.oc1.sa-saopaulo-1.example"
    functions = {
      hello = {
        image = "sa-saopaulo-1.ocir.io/example/hello:1.0"
      }
    }
  }

  assert {
    condition     = oci_functions_function.this["hello"].source_details[0].source_type == "CONTAINER_IMAGE" && oci_functions_function.this["hello"].source_details[0].image == "sa-saopaulo-1.ocir.io/example/hello:1.0" && oci_functions_function.this["hello"].application_id == "ocid1.fnapp.oc1.sa-saopaulo-1.example"
    error_message = "The function must use the provider's container-image source block and existing application."
  }
}

run "deployment_uses_existing_gateway" {
  command = plan
  variables {
    enable_api_gateway_deployment = true
    gateway_id                    = "ocid1.apigateway.oc1.sa-saopaulo-1.example"
    api_routes = {
      hello = {
        path        = "/hello"
        methods     = ["GET"]
        function_id = "ocid1.fnfunc.oc1.sa-saopaulo-1.example"
      }
    }
  }

  assert {
    condition     = length(oci_apigateway_gateway.this) == 0 && oci_apigateway_deployment.this[0].gateway_id == "ocid1.apigateway.oc1.sa-saopaulo-1.example"
    error_message = "A deployment on an existing gateway must use its supplied ID without creating a new gateway."
  }
}
