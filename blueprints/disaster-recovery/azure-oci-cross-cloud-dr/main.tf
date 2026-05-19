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
}

resource "terraform_data" "dns_failover_contract" {
  count = var.enable_dns_failover_contract ? 1 : 0

  input = local.dns_failover_contract
}

resource "terraform_data" "runbook_contract" {
  count = var.enable_runbook_contract ? 1 : 0

  input = local.runbook_contract
}
