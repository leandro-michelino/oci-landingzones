mock_provider "oci" {
  mock_data "oci_core_services" {
    defaults = { services = [{ id = "ocid1.service.oc1..example", name = "All GRU Services In Oracle Services Network", cidr_block = "all-gru-services-in-oracle-services-network"
      }]
    }

  }
  mock_data "oci_objectstorage_namespace" {
    defaults = { namespace = "example"
    }
  }
  mock_resource "oci_core_instance" {
    defaults = { private_ip = "10.120.20.10", boot_volume_id = "ocid1.bootvolume.oc1..example"
    }

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
    condition     = length(oci_core_vcn.this) == 0 && length(oci_core_instance.application) == 0 && length(oci_database_autonomous_database.clinical) == 0 && length(oci_objectstorage_bucket.documents) == 0
    error_message = "Defaults must create no cloud resources."

  }
}
run "private_foundation" {
  command = plan
  variables {
    enable_foundation = true
    costs_approved    = true

  }
  assert {
    condition     = alltrue([for sn in oci_core_subnet.private : sn.prohibit_public_ip_on_vnic]) && length(oci_core_subnet.private) == 3 && length(oci_logging_log.flow) == 3 && length(oci_core_drg_attachment.hospital) == 0
    error_message = "Foundation must retain three private logged subnets without external attachment by default."

  }
  assert {
    condition     = length(oci_core_route_table.private[0].route_rules) == 1 && one(oci_core_route_table.private[0].route_rules).destination_type == "SERVICE_CIDR_BLOCK" && length(oci_core_security_list.empty[0].egress_security_rules) == 0
    error_message = "Foundation must have only a regional OSN route and no broad security-list egress."

  }
}
run "cost_approval_required" {
  command = plan
  variables {
    enable_foundation = true
  }
  expect_failures = [terraform_data.guard]
}
run "workloads_require_foundation" {
  command = plan
  variables {
    enable_database = true
  }
  expect_failures = [terraform_data.guard]
}
run "kms_permission_required" {
  command = plan
  variables {
    enable_foundation = true
    costs_approved    = true
    enable_documents  = true

  }
  expect_failures = [terraform_data.guard]
}
run "overlapping_subnets_rejected" {
  command = plan
  variables {
    subnet_cidrs = { ingress = "10.120.10.0/24", application = "10.120.10.0/24", database = "10.120.30.0/24"
    }
  }
  expect_failures = [terraform_data.guard]
}
run "internet_client_prefix_rejected" {
  command = plan
  variables {
    hospital_client_cidrs = ["0.0.0.0/0"]
  }
  expect_failures = [terraform_data.guard]
}
run "encrypted_data_services" {
  command = plan
  variables {
    enable_foundation       = true
    costs_approved          = true
    enable_database         = true
    enable_documents        = true
    kms_key_id              = "ocid1.key.oc1..example"
    kms_policies_ready      = true
    database_admin_password = "MockOnly-DoNotUse_2026"

  }
  assert {
    condition     = oci_database_autonomous_database.clinical[0].is_mtls_connection_required && !oci_database_autonomous_database.clinical[0].is_auto_scaling_enabled && oci_objectstorage_bucket.documents[0].access_type == "NoPublicAccess" && oci_objectstorage_bucket.documents[0].versioning == "Enabled" && oci_objectstorage_bucket.documents[0].kms_key_id == var.kms_key_id
    error_message = "Data services must retain private endpoint, mTLS and encrypted/versioned document configuration."

  }
}
run "application_requires_handoffs" {
  command = plan
  variables {
    enable_foundation  = true
    costs_approved     = true
    enable_application = true
    kms_key_id         = "ocid1.key.oc1..example"
    kms_policies_ready = true

  }
  expect_failures = [terraform_data.guard]
}
run "configured_private_application" {
  command = plan
  variables {
    enable_foundation     = true
    costs_approved        = true
    enable_application    = true
    kms_key_id            = "ocid1.key.oc1..example"
    kms_policies_ready    = true
    drg_id                = "ocid1.drg.oc1..example"
    hospital_client_cidrs = ["10.200.0.0/16"]
    application_instances = { app1 = { availability_domain = "example:SA-SAOPAULO-1-AD-1", image_id = "ocid1.image.oc1..example"
      }
    }
    boot_volume_backup_policy_id = "ocid1.volumebackuppolicy.oc1..example"
    tls_public_certificate       = "mock-certificate-not-deployable"
    tls_private_key              = "mock-key-not-deployable"
    backend_trusted_ca_ids       = ["ocid1.certificateauthority.oc1..example"]

  }
  assert {
    condition     = oci_load_balancer_load_balancer.private[0].is_private && !oci_core_instance.application["app1"].create_vnic_details[0].assign_public_ip && oci_core_instance.application["app1"].instance_options[0].are_legacy_imds_endpoints_disabled && oci_load_balancer_backend_set.application[0].ssl_configuration[0].verify_peer_certificate && length(oci_core_volume_backup_policy_assignment.application) == 1
    error_message = "Application must retain private ingress, IMDSv2, backend peer validation and backup assignments."

  }
}
