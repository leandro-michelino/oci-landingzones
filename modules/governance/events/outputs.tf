# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
output "module_name" {
  description = "Module identifier."
  value       = local.module_name
}

output "name_prefix" {
  description = "Standard OCI naming prefix for resources created by this module."
  value       = local.name_prefix
}

output "cis_level" {
  description = "Selected CIS OCI Benchmark profile."
  value       = local.cis_level
}

output "resource_ids" {
  description = "Map of resource identifiers created by this module."
  value = merge(
    {
      for key, topic in oci_ons_notification_topic.this : "topic.${key}" => topic.id
    },
    {
      for key, subscription in oci_ons_subscription.this : "subscription.${key}" => subscription.id
    },
    {
      for key, rule in oci_events_rule.this : "event_rule.${key}" => rule.id
    }
  )
}

output "notification_topic_ids" {
  description = "Map of notification topic keys to OCIDs."
  value = {
    for key, topic in oci_ons_notification_topic.this : key => topic.id
  }
}

output "notification_topic_names" {
  description = "Map of notification topic keys to names."
  value = {
    for key, topic in oci_ons_notification_topic.this : key => topic.name
  }
}

output "subscription_ids" {
  description = "Map of subscription keys to OCIDs."
  value = {
    for key, subscription in oci_ons_subscription.this : key => subscription.id
  }
}

output "event_rule_ids" {
  description = "Map of event rule keys to OCIDs."
  value = {
    for key, rule in oci_events_rule.this : key => rule.id
  }
}

output "event_rule_names" {
  description = "Map of event rule keys to display names."
  value = {
    for key, rule in oci_events_rule.this : key => rule.display_name
  }
}
