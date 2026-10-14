# Last successful validation: 2026-10-14 | blueprint Terraform init/validate | oracle/oci 9.9.0.
# Scope: schema validation only; full live lifecycle not verified.
# Evidence: docs/EPHEMERAL-DEPLOYMENT-EVIDENCE.md; module call validated in this blueprint context.
resource "oci_waf_web_app_firewall_policy" "this" {
  count = var.enable_waf_policy ? 1 : 0

  compartment_id = local.target_compartment_ocid
  display_name   = local.policy_name
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_waf_web_app_firewall" "this" {
  count = var.enable_web_app_firewall ? 1 : 0

  backend_type               = var.backend_type
  compartment_id             = local.target_compartment_ocid
  load_balancer_id           = var.load_balancer_id
  web_app_firewall_policy_id = local.waf_policy_id
  display_name               = local.firewall_name
  defined_tags               = var.defined_tags
  freeform_tags              = local.common_freeform_tags
}
