# ZPR Module

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This Terraform module creates OCI Zero Packet Routing configuration and ZPR policies when enabled.

## What It Creates

- `oci_zpr_configuration`
- `oci_zpr_zpr_policy`

## Key Inputs

- `enable_zpr_configuration`
- `zpr_status`
- `enable_zpr_policies`
- `zpr_policies`

## Outputs

- `zpr_configuration_id`
- `zpr_policy_ids`

## Usage Notes

- ZPR should be enabled only after policy scope and attributes are reviewed.
- Use with network security controls rather than as a replacement for them.

## Contract

The module follows the repository module contract for `tenancy_ocid`, `compartment_ocid`, `region`, `org`, `environment`, `region_key`, `cis_level`, `defined_tags`, and `freeform_tags` where those inputs apply.
