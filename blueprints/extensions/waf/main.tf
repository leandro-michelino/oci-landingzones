# Last successful validation: 2026-10-23 | blueprint Terraform validate | oracle/oci 9.10.0.
# Scope: schema, 4 mocked plans, DEFAULT Sao Paulo no-change and policy creation plans; no apply.
# Correction: firewall attachment now requires a load balancer and an effective policy ID.
# Evidence: docs/EXTENSIONS-IDENTITY-REVIEW-20261023.md; no WAF policy or attachment was applied.
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

  lifecycle {
    # Reject incomplete attachments before OCI receives a create request.
    precondition {
      condition     = var.load_balancer_id != null
      error_message = "A Web App Firewall attachment requires load_balancer_id."
    }
    precondition {
      condition     = local.waf_policy_id != null
      error_message = "A Web App Firewall attachment requires an existing waf_policy_id or enable_waf_policy=true."
    }
  }
}
