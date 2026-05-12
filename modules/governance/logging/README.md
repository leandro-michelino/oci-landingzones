# Logging Module

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This Terraform module creates log groups, service logs, saved searches, and optional tenancy audit retention configuration.

## What It Creates

- `oci_logging_log_group`
- `oci_logging_log`
- `oci_logging_log_saved_search`
- `oci_audit_configuration`

## Key Inputs

- `enable_logging`
- `log_groups`
- `service_logs`
- `vcn_flow_logs`
- `saved_searches`
- `enable_audit_retention`

## Outputs

- `log_group_ids`
- `service_log_ids`
- `saved_search_ids`
- `audit_configuration_id`

## Usage Notes

- Service and VCN flow logs need real source resource OCIDs.
- Audit retention is tenancy-wide and should be enabled deliberately outside generic smoke tests.

## Contract

The module follows the repository module contract for `tenancy_ocid`, `compartment_ocid`, `region`, `org`, `environment`, `region_key`, `cis_level`, `defined_tags`, and `freeform_tags` where those inputs apply.
