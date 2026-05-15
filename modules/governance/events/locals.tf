# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  module_name = "governance-events"
  cis_level   = var.cis_level == null ? null : lower(var.cis_level)
  name_prefix = "${var.org}-${var.environment}-${var.region_key}"

  default_topics = var.enable_events && var.enable_default_topic ? {
    default = {
      name             = "${local.name_prefix}-top-governance-events"
      description      = "Landing zone governance event notifications managed by Terraform."
      compartment_ocid = var.compartment_ocid
    }
  } : {}

  notification_topics = var.enable_events ? merge(local.default_topics, var.notification_topics) : {}

  default_event_action = [
    {
      action_type = "ONS"
      description = "Publish governance event to the default notification topic."
      function_id = null
      is_enabled  = true
      stream_id   = null
      topic_key   = "default"
      topic_id    = null
    }
  ]

  default_event_rules = var.enable_events && var.enable_default_event_rules && contains(keys(local.notification_topics), "default") ? {
    iam_policy_changes = {
      display_name     = "${local.name_prefix}-evt-iam-policy-changes"
      description      = "Governance notification for IAM policy changes."
      compartment_ocid = var.tenancy_ocid
      condition = jsonencode({
        eventType = [
          "com.oraclecloud.identityControlPlane.CreatePolicy",
          "com.oraclecloud.identityControlPlane.UpdatePolicy",
          "com.oraclecloud.identityControlPlane.DeletePolicy"
        ]
      })
      is_enabled = true
      actions    = local.default_event_action
    }
    iam_group_membership_changes = {
      display_name     = "${local.name_prefix}-evt-iam-group-membership"
      description      = "Governance notification for IAM group membership changes."
      compartment_ocid = var.tenancy_ocid
      condition = jsonencode({
        eventType = [
          "com.oraclecloud.identityControlPlane.AddUserToGroup",
          "com.oraclecloud.identityControlPlane.RemoveUserFromGroup"
        ]
      })
      is_enabled = true
      actions    = local.default_event_action
    }
    iam_credential_changes = {
      display_name     = "${local.name_prefix}-evt-iam-credential-changes"
      description      = "Governance notification for IAM credential changes."
      compartment_ocid = var.tenancy_ocid
      condition = jsonencode({
        eventType = [
          "com.oraclecloud.identityControlPlane.UploadApiKey",
          "com.oraclecloud.identityControlPlane.DeleteApiKey",
          "com.oraclecloud.identityControlPlane.CreateAuthToken",
          "com.oraclecloud.identityControlPlane.DeleteAuthToken",
          "com.oraclecloud.identityControlPlane.CreateCustomerSecretKey",
          "com.oraclecloud.identityControlPlane.DeleteCustomerSecretKey"
        ]
      })
      is_enabled = true
      actions    = local.default_event_action
    }
  } : {}

  event_rules = var.enable_events ? merge(local.default_event_rules, var.event_rules) : {}

  subscriptions = var.enable_events ? var.subscriptions : {}

  common_freeform_tags = merge(
    var.freeform_tags,
    {
      Module = local.module_name
    }
  )
}
