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
run "function_action_without_ons_topic" {
  command = plan
  variables {
    event_rules = {
      function = { condition = "{\"eventType\":\"mock.event\"}", actions = [{ action_type = "FAAS", function_id = "ocid1.fnfunc.oc1..example" }] }
    }
  }
  assert {
    condition     = one(one(oci_events_rule.this["function"].actions).actions).function_id == "ocid1.fnfunc.oc1..example"
    error_message = "Function actions must plan without an unrelated ONS topic."
  }
}
run "streaming_action_without_ons_topic" {
  command = plan
  variables {
    event_rules = {
      stream = { condition = "{\"eventType\":\"mock.event\"}", actions = [{ action_type = "OSS", stream_id = "ocid1.stream.oc1..example" }] }
    }
  }
  assert {
    condition     = one(one(oci_events_rule.this["stream"].actions).actions).stream_id == "ocid1.stream.oc1..example"
    error_message = "Streaming actions must plan without an unrelated ONS topic."
  }
}
