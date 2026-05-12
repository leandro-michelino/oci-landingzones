# Policies Module

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This Terraform module creates OCI IAM policies from default and custom policy statement maps.

## What It Creates

- `oci_identity_policy`

## Key Inputs

- `enable_default_policies`
- `group_names`
- `dynamic_group_names`
- `compartment_names`
- `policies`

## Outputs

- `policy_ids`
- `policy_names`
- `policy_statements`

## Usage Notes

- Policies are attached to `compartment_ocid` and should use least-privilege compartment paths.
- Review generated statements before applying in production.

## Contract

The module follows the repository module contract for `tenancy_ocid`, `compartment_ocid`, `region`, `org`, `environment`, `region_key`, `cis_level`, `defined_tags`, and `freeform_tags` where those inputs apply.
