# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
data "oci_objectstorage_namespace" "this" {
  compartment_id = local.target_compartment_ocid
}

resource "oci_objectstorage_bucket" "dr_evidence" {
  count = var.enable_dr_evidence_bucket ? 1 : 0

  compartment_id = local.target_compartment_ocid
  namespace      = data.oci_objectstorage_namespace.this.namespace
  name           = local.evidence_bucket_name

  storage_tier = "Standard"
  versioning   = "Enabled"

  defined_tags  = var.defined_tags
  freeform_tags = local.common_freeform_tags
}

resource "oci_ons_notification_topic" "dr_alert" {
  count = var.enable_dr_alert_topic ? 1 : 0

  compartment_id = local.target_compartment_ocid
  name           = local.alert_topic_name
  description    = var.dr_alert_topic_description

  defined_tags  = var.defined_tags
  freeform_tags = local.common_freeform_tags
}

resource "terraform_data" "connectivity_contract" {
  input = local.effective_interconnect

  lifecycle {
    precondition {
      condition = (
        var.connectivity_mode == "interconnect" &&
        var.fastconnect_virtual_circuit_id != null &&
        var.expressroute_circuit_id != null
        ) || (
        var.connectivity_mode == "without-interconnect" &&
        var.fastconnect_virtual_circuit_id == null &&
        var.expressroute_circuit_id == null
      )
      error_message = "For connectivity_mode=interconnect, set both fastconnect_virtual_circuit_id and expressroute_circuit_id. For connectivity_mode=without-interconnect, keep both values null."
    }
  }
}

resource "terraform_data" "dns_failover_contract" {
  count = var.enable_dns_failover_contract ? 1 : 0

  input = local.dns_failover_contract

  lifecycle {
    precondition {
      condition = (
        var.oci_primary_endpoint != null &&
        var.azure_standby_endpoint != null &&
        trimspace(var.app_fqdn) != ""
      )
      error_message = "When enable_dns_failover_contract=true, set app_fqdn, oci_primary_endpoint, and azure_standby_endpoint."
    }
  }
}

resource "terraform_data" "runbook_contract" {
  count = var.enable_runbook_contract ? 1 : 0

  input = local.runbook_contract
}
