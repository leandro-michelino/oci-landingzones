mock_provider "oci" {
  mock_data "oci_core_services" {
    defaults = { services = [{ id = "ocid1.service.oc1..example", name = "All GRU Services In Oracle Services Network", cidr_block = "all-gru-services-in-oracle-services-network" }] }
  }
}
variables {
  tenancy_ocid     = "ocid1.tenancy.oc1..example"
  compartment_ocid = "ocid1.compartment.oc1..example"
  region           = "sa-saopaulo-1"
  org              = "hospital"
  environment      = "test"
  region_key       = "gru"
}
run "disabled_defaults" {
  command = plan
  assert {
    condition     = length(oci_core_vcn.this) == 0 && length(oci_apigateway_gateway.fhir) == 0 && length(oci_queue_queue.integration) == 0
    error_message = "Defaults must not create cloud resources."
  }
}
run "private_foundation" {
  command = plan
  variables {
    enable_foundation = true
    costs_approved    = true
  }
  assert {
    condition     = length(oci_core_subnet.private) == 2 && alltrue([for sn in oci_core_subnet.private : sn.prohibit_public_ip_on_vnic]) && length(oci_core_route_table.private[0].route_rules) == 1 && length(oci_logging_log.flow) == 2
    error_message = "Foundation must contain two private logged subnets with only the OSN route."
  }
}
run "cost_guard" {
  command = plan
  variables {
    enable_foundation = true
  }
  expect_failures = [terraform_data.guard]
}
run "api_requires_identity_and_backend" {
  command = plan
  variables {
    enable_foundation = true
    costs_approved    = true
    enable_api        = true
  }
  expect_failures = [terraform_data.guard]
}
run "queue_requires_key_permissions" {
  command = plan
  variables {
    enable_foundation = true
    costs_approved    = true
    enable_queue      = true
  }
  expect_failures = [terraform_data.guard]
}
run "internet_prefix_rejected" {
  command = plan
  variables {
    fhir_backend_cidrs = ["0.0.0.0/0"]
  }
  expect_failures = [terraform_data.guard]
}
run "overlapping_subnets_rejected" {
  command = plan
  variables {
    subnet_cidrs = { api = "10.121.10.0/24", integration = "10.121.10.0/24" }
  }
  expect_failures = [terraform_data.guard]
}
run "delete_method_rejected" {
  command = plan
  variables {
    allowed_methods = ["GET", "DELETE"]
  }
  expect_failures = [terraform_data.guard]
}
run "configured_authenticated_api" {
  command = plan
  variables {
    enable_foundation                = true
    costs_approved                   = true
    enable_api                       = true
    ca_bundle_ids                    = ["ocid1.cabundle.oc1..example"]
    drg_id                           = "ocid1.drg.oc1..example"
    hospital_client_cidrs            = ["10.200.0.0/16"]
    fhir_backend_cidrs               = ["10.120.10.0/24"]
    jwks_cidrs                       = ["10.200.10.0/24"]
    fhir_backend_url                 = "https://fhir.example.internal/fhir"
    fhir_backend_authorization_ready = true
    jwks_uri                         = "https://identity.example.internal/keys"
    jwt_issuers                      = ["https://identity.example.internal"]
    jwt_audiences                    = ["hospital-fhir"]
  }
  assert {
    condition     = oci_apigateway_gateway.fhir[0].endpoint_type == "PRIVATE" && length(oci_apigateway_gateway.fhir[0].ca_bundles) == 1 && !oci_apigateway_deployment.fhir[0].specification[0].request_policies[0].authentication[0].is_anonymous_access_allowed && oci_apigateway_deployment.fhir[0].specification[0].request_policies[0].authentication[0].type == "TOKEN_AUTHENTICATION" && !oci_apigateway_deployment.fhir[0].specification[0].request_policies[0].authentication[0].validation_policy[0].is_ssl_verify_disabled
    error_message = "API must retain private access, token authentication and JWKS TLS verification."
  }
  assert {
    condition     = length(oci_apigateway_deployment.fhir[0].specification[0].routes) == 11 && alltrue([for route in oci_apigateway_deployment.fhir[0].specification[0].routes : toset(route.methods) == toset(["GET"]) && !route.backend[0].is_ssl_verify_disabled])
    error_message = "Default FHIR routes must be GET only, with backend TLS validation."
  }
  assert {
    condition     = anytrue([for route in oci_apigateway_deployment.fhir[0].specification[0].routes : route.path == "/Patient/{id}" && route.backend[0].url == "https://fhir.example.internal/fhir/Patient/$${request.path[id]}"])
    error_message = "Resource IDs must remain bound to the configured route path, not a constant backend URL."
  }
}
run "encrypted_queue_settings" {
  command = plan
  variables {
    enable_foundation  = true
    costs_approved     = true
    enable_queue       = true
    kms_key_id         = "ocid1.key.oc1..example"
    kms_policies_ready = true
  }
  assert {
    condition     = oci_queue_queue.integration[0].custom_encryption_key_id == var.kms_key_id && oci_queue_queue.integration[0].dead_letter_queue_delivery_count == 5 && oci_queue_queue.integration[0].retention_in_seconds == 86400
    error_message = "Queue must retain customer key, finite event retention and native dead-letter delivery settings."
  }
}

run "write_methods_follow_fhir_interactions" {
  command = plan
  variables {
    allowed_methods                  = ["GET", "POST", "PUT", "PATCH"]
    enable_foundation                = true
    costs_approved                   = true
    enable_api                       = true
    ca_bundle_ids                    = ["ocid1.cabundle.oc1..example"]
    drg_id                           = "ocid1.drg.oc1..example"
    hospital_client_cidrs            = ["10.200.0.0/16"]
    fhir_backend_cidrs               = ["10.120.10.0/24"]
    jwks_cidrs                       = ["10.200.10.0/24"]
    fhir_backend_url                 = "https://fhir.example.internal/fhir"
    fhir_backend_authorization_ready = true
    jwks_uri                         = "https://identity.example.internal/keys"
    jwt_issuers                      = ["https://identity.example.internal"]
    jwt_audiences                    = ["hospital-fhir"]
  }
  assert {
    condition     = oci_apigateway_gateway.fhir[0].endpoint_type == "PRIVATE" && length(oci_apigateway_gateway.fhir[0].ca_bundles) == 1 && !oci_apigateway_deployment.fhir[0].specification[0].request_policies[0].authentication[0].is_anonymous_access_allowed && oci_apigateway_deployment.fhir[0].specification[0].request_policies[0].authentication[0].type == "TOKEN_AUTHENTICATION" && !oci_apigateway_deployment.fhir[0].specification[0].request_policies[0].authentication[0].validation_policy[0].is_ssl_verify_disabled
    error_message = "API must retain private access, token authentication and JWKS TLS verification."
  }
  assert {
    condition     = length(oci_apigateway_deployment.fhir[0].specification[0].routes) == 11 && alltrue([for route in oci_apigateway_deployment.fhir[0].specification[0].routes : (endswith(route.path, "{id}") ? !contains(route.methods, "POST") : (!contains(route.methods, "PUT") && !contains(route.methods, "PATCH"))) && !route.backend[0].is_ssl_verify_disabled])
    error_message = "Writes must follow collection POST versus instance PUT/PATCH, with backend TLS validation."
  }
  assert {
    condition     = anytrue([for route in oci_apigateway_deployment.fhir[0].specification[0].routes : route.path == "/Patient/{id}" && route.backend[0].url == "https://fhir.example.internal/fhir/Patient/$${request.path[id]}"])
    error_message = "Resource IDs must remain bound to the configured route path, not a constant backend URL."
  }
}
