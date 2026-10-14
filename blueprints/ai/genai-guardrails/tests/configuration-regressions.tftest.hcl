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
run "streaming_target_without_object_storage" {
  command = plan
  variables {
    create_service_connector      = true
    connector_source_log_group_id = "ocid1.loggroup.oc1..example"
    connector_target_kind         = "streaming"
    connector_target_stream_id    = "ocid1.stream.oc1..example"
  }
  assert {
    condition     = oci_sch_service_connector.audit[0].target[0].stream_id == var.connector_target_stream_id
    error_message = "Streaming must not evaluate or populate Object Storage target fields."
  }
}
run "object_storage_requires_namespace" {
  command = plan
  variables {
    create_service_connector      = true
    connector_source_log_group_id = "ocid1.loggroup.oc1..example"
    connector_target_kind         = "objectStorage"
  }
  expect_failures = [oci_sch_service_connector.audit]
}
run "existing_object_storage_target" {
  command = plan
  variables {
    create_service_connector      = true
    connector_source_log_group_id = "ocid1.loggroup.oc1..example"
    connector_target_kind         = "objectStorage"
    connector_target_namespace    = "mocknamespace"
    connector_target_bucket       = "existing-audit"
  }
  assert {
    condition     = oci_sch_service_connector.audit[0].target[0].namespace == "mocknamespace" && oci_sch_service_connector.audit[0].target[0].bucket == "existing-audit"
    error_message = "Object Storage must preserve its namespace without adding a stream target."
  }
}
