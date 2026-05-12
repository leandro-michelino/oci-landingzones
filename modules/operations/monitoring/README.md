# Monitoring Module

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This Terraform module creates notification topics, subscriptions, and Monitoring alarms.

## What It Creates

- `oci_ons_notification_topic`
- `oci_ons_subscription`
- `oci_monitoring_alarm`

## Key Inputs

- `enable_monitoring`
- `enable_default_topic`
- `notification_topics`
- `subscriptions`
- `alarms`

## Outputs

- `notification_topic_ids`
- `subscription_ids`
- `alarm_ids`
- `alarm_names`

## Usage Notes

- Alarm queries and destinations should be environment-specific.
- Subscriptions may require confirmation outside Terraform.

## Contract

The module follows the repository module contract for `tenancy_ocid`, `compartment_ocid`, `region`, `org`, `environment`, `region_key`, `cis_level`, `defined_tags`, and `freeform_tags` where those inputs apply.
