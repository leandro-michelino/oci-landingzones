# Groups Module

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This Terraform module creates OCI IAM groups, including optional default platform groups.

## What It Creates

- `oci_identity_group`

## Key Inputs

- `enable_default_groups`
- `groups`
- `org`
- `environment`
- `region_key`

## Outputs

- `group_ids`
- `group_names`

## Usage Notes

- Groups contain no membership assignments; membership stays an operational identity-domain task.
- Disable default groups only for quota-constrained or highly custom tests.

## Contract

The module follows the repository module contract for `tenancy_ocid`, `compartment_ocid`, `region`, `org`, `environment`, `region_key`, `cis_level`, `defined_tags`, and `freeform_tags` where those inputs apply.
