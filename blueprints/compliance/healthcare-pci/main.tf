# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
resource "oci_identity_policy" "guardrails" {
  count = length(var.guardrail_policy_statements) > 0 ? 1 : 0

  compartment_id = local.policy_compartment_ocid
  name           = "${local.name_prefix}-regulated-guardrails"
  description    = "Healthcare and PCI landing-zone guardrail policy for ${local.name_prefix}."
  statements     = var.guardrail_policy_statements
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_budget_budget" "this" {
  count = var.enable_budget ? 1 : 0

  compartment_id        = local.target_compartment_ocid
  target_compartment_id = local.target_compartment_ocid
  target_type           = "COMPARTMENT"
  reset_period          = var.budget_reset_period
  amount                = var.budget_amount
  display_name          = "${local.name_prefix}-regulated-budget"
  description           = "Regulated workload budget for ${local.name_prefix}."
  defined_tags          = var.defined_tags
  freeform_tags         = local.common_freeform_tags
}

resource "oci_budget_alert_rule" "this" {
  count = var.enable_budget && var.budget_alert_recipients != null ? 1 : 0

  budget_id      = oci_budget_budget.this[0].id
  display_name   = "${local.name_prefix}-regulated-budget-alert"
  description    = "Regulated workload budget alert."
  threshold      = var.budget_alert_threshold
  threshold_type = var.budget_alert_threshold_type
  type           = var.budget_alert_type
  recipients     = var.budget_alert_recipients
  message        = var.budget_alert_message
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}

resource "oci_data_safe_target_database" "this" {
  count = var.enable_data_safe_target_database ? 1 : 0

  compartment_id = local.target_compartment_ocid
  display_name   = "${local.name_prefix}-datasafe-target"
  description    = "Data Safe target database registration for regulated workloads."
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags

  database_details {
    database_type          = var.data_safe_database_type
    infrastructure_type    = var.data_safe_infrastructure_type
    autonomous_database_id = var.data_safe_autonomous_database_id
    service_name           = var.data_safe_service_name
  }

  dynamic "credentials" {
    for_each = var.data_safe_user_name == null || var.data_safe_password == null ? [] : [1]

    content {
      user_name = var.data_safe_user_name
      password  = var.data_safe_password
    }
  }
}
