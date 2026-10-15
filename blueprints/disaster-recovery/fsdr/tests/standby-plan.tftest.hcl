mock_provider "oci" {
  mock_data "oci_objectstorage_namespace" {
    defaults = { namespace = "mock-namespace" }
  }
}

mock_provider "oci" {
  alias = "standby"
  mock_data "oci_objectstorage_namespace" {
    defaults = { namespace = "mock-namespace" }
  }
}

variables {
  tenancy_ocid       = "ocid1.tenancy.oc1..example"
  compartment_ocid   = "ocid1.compartment.oc1..example"
  region             = "sa-saopaulo-1"
  standby_region     = "us-ashburn-1"
  oci_config_profile = "DEFAULT"
  org                = "test"
  environment        = "dev"
  region_key         = "sao"
  standby_region_key = "iad"
}

run "disabled_configuration_reads_no_namespace" {
  command = plan
  variables {
    enable_dr_log_buckets       = false
    enable_dr_protection_groups = false
  }

  assert {
    condition = (
      length(data.oci_objectstorage_namespace.primary) == 0 &&
      length(data.oci_objectstorage_namespace.standby) == 0 &&
      length(oci_objectstorage_bucket.primary_dr_logs) == 0 &&
      length(oci_disaster_recovery_dr_protection_group.primary) == 0 &&
      length(oci_disaster_recovery_dr_plan.standby) == 0
    )
    error_message = "The explicitly disabled FSDR configuration must not read namespaces or create resources."
  }
}

run "plan_requires_protection_groups" {
  command = plan
  variables {
    enable_dr_log_buckets       = false
    enable_dr_protection_groups = false
    enable_dr_plan              = true
  }
  expect_failures = [var.enable_dr_plan]
}

run "existing_log_buckets_require_names" {
  command = plan
  variables {
    enable_dr_log_buckets       = false
    enable_dr_protection_groups = true
  }
  expect_failures = [var.enable_dr_protection_groups]
}

run "cross_region_is_required" {
  command = plan
  variables { standby_region = "sa-saopaulo-1" }
  expect_failures = [var.standby_region]
}

run "existing_log_buckets_are_referenced_without_creation" {
  command = plan
  variables {
    enable_dr_log_buckets       = false
    enable_dr_protection_groups = true
    primary_log_bucket_name     = "mock-primary-logs"
    standby_log_bucket_name     = "mock-standby-logs"
  }

  assert {
    condition = (
      length(oci_objectstorage_bucket.primary_dr_logs) == 0 &&
      length(oci_objectstorage_bucket.standby_dr_logs) == 0 &&
      length(oci_disaster_recovery_dr_protection_group.primary) == 1 &&
      length(oci_disaster_recovery_dr_protection_group.standby) == 1
    )
    error_message = "Named existing log buckets must not be recreated by this blueprint."
  }
}

run "standby_group_owns_the_plan" {
  command = apply
  variables {
    enable_dr_log_buckets       = true
    enable_dr_protection_groups = true
    enable_dr_plan              = true
  }

  assert {
    condition = (
      oci_disaster_recovery_dr_protection_group.standby[0].association[0].role == "STANDBY" &&
      oci_disaster_recovery_dr_protection_group.standby[0].association[0].peer_id == oci_disaster_recovery_dr_protection_group.primary[0].id &&
      oci_disaster_recovery_dr_protection_group.standby[0].association[0].peer_region == var.region &&
      oci_disaster_recovery_dr_plan.standby[0].dr_protection_group_id == oci_disaster_recovery_dr_protection_group.standby[0].id &&
      output.standby_dr_plan_id == oci_disaster_recovery_dr_plan.standby[0].id
    )
    error_message = "Only an associated standby protection group may own the DR plan."
  }
}
