# Last successful validation: 2026-10-14 | Terraform init/validate | oracle/oci 9.9.0.
# Scope: isolated module schema validation; no live apply or traffic verification.
# Evidence: docs/EPHEMERAL-DEPLOYMENT-EVIDENCE.md (module validation metadata).
resource "oci_network_firewall_network_firewall_policy" "this" {
  count = var.enable_network_firewall && var.network_firewall_policy_id == null ? 1 : 0

  compartment_id = var.compartment_ocid
  display_name   = coalesce(var.policy_display_name, "${local.name_prefix}-nfwpol-${var.firewall_label}")
  description    = var.policy_description
  defined_tags   = var.defined_tags
  freeform_tags  = var.freeform_tags
}

resource "oci_network_firewall_network_firewall" "this" {
  count = var.enable_network_firewall ? 1 : 0

  compartment_id             = var.compartment_ocid
  display_name               = coalesce(var.firewall_display_name, "${local.name_prefix}-nfw-${var.firewall_label}")
  network_firewall_policy_id = local.policy_id
  subnet_id                  = var.subnet_id
  network_security_group_ids = var.network_security_group_ids
  availability_domain        = var.availability_domain
  defined_tags               = var.defined_tags
  freeform_tags              = var.freeform_tags
}
