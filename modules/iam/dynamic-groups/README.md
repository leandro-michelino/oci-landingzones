# Dynamic Groups Module

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This Terraform module creates OCI dynamic groups for automation and resource-principal access patterns.

## What It Creates

- `oci_identity_dynamic_group`

## Key Inputs

- `dynamic_groups`
- `tenancy_ocid`
- `org`
- `environment`
- `region_key`

## Outputs

- `dynamic_group_ids`
- `dynamic_group_names`

## Usage Notes

- Matching rules should be tightly scoped to approved automation and workload resources.
- Policies that grant access to dynamic groups are managed separately by the policies module.

## Contract

The module follows the repository module contract for `tenancy_ocid`, `compartment_ocid`, `region`, `org`, `environment`, `region_key`, `cis_level`, `defined_tags`, and `freeform_tags` where those inputs apply.
