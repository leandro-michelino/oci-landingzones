# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
resource "oci_budget_budget" "this" {
  for_each = local.budgets

  compartment_id                        = coalesce(each.value.compartment_ocid, var.compartment_ocid)
  amount                                = each.value.amount
  reset_period                          = upper(each.value.reset_period)
  budget_processing_period_start_offset = each.value.budget_processing_period_start_offset
  description                           = coalesce(each.value.description, "Landing zone budget ${each.key} managed by Terraform.")
  display_name                          = coalesce(each.value.display_name, "${local.name_prefix}-budget-${each.key}")
  end_date                              = each.value.end_date
  processing_period_type                = each.value.processing_period_type
  start_date                            = each.value.start_date
  target_type                           = upper(each.value.target_type)
  targets                               = length(each.value.targets) > 0 ? tolist(each.value.targets) : (upper(each.value.target_type) == "COMPARTMENT" ? [coalesce(each.value.compartment_ocid, var.compartment_ocid)] : null)
  defined_tags                          = var.defined_tags
  freeform_tags                         = local.common_freeform_tags
}

resource "oci_budget_alert_rule" "this" {
  for_each = local.alert_rules

  budget_id      = oci_budget_budget.this[each.value.budget_key].id
  display_name   = coalesce(each.value.display_name, "${local.name_prefix}-budget-alert-${each.value.budget_key}-${each.value.rule_key}")
  description    = coalesce(each.value.description, "Budget alert ${each.value.rule_key} for ${each.value.budget_key}.")
  message        = each.value.message
  recipients     = each.value.recipients
  threshold      = each.value.threshold
  threshold_type = upper(each.value.threshold_type)
  type           = upper(each.value.type)
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}
