# Events Module

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This Terraform module creates notification topics, subscriptions, and OCI Events rules for governance signals.

## What It Creates

- `oci_ons_notification_topic`
- `oci_ons_subscription`
- `oci_events_rule`

## Key Inputs

- `enable_events`
- `enable_default_topic`
- `enable_default_event_rules`
- `notification_topics`
- `subscriptions`
- `event_rules`

## Outputs

- `notification_topic_ids`
- `subscription_ids`
- `event_rule_ids`

## Usage Notes

- Subscriptions require approved endpoints and may need confirmation outside Terraform.
- Use this module for operational signals such as IAM change events.

## Contract

The module follows the repository module contract for `tenancy_ocid`, `compartment_ocid`, `region`, `org`, `environment`, `region_key`, `cis_level`, `defined_tags`, and `freeform_tags` where those inputs apply.
