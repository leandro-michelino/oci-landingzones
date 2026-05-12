# Cloud Guard Module

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This Terraform module configures Cloud Guard and optional Cloud Guard targets.

## What It Creates

- `oci_cloud_guard_cloud_guard_configuration`
- `oci_cloud_guard_target`

## Key Inputs

- `enable_cloud_guard`
- `cloud_guard_status`
- `reporting_region`
- `self_manage_resources`
- `enable_default_target`
- `targets`

## Outputs

- `cloud_guard_configuration_id`
- `target_ids`
- `target_names`

## Usage Notes

- Cloud Guard configuration is tenancy-wide and should be enabled deliberately.
- Custom detector and responder recipes should be approved before apply.

## Contract

The module follows the repository module contract for `tenancy_ocid`, `compartment_ocid`, `region`, `org`, `environment`, `region_key`, `cis_level`, `defined_tags`, and `freeform_tags` where those inputs apply.
