# Vault Module

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This Terraform module creates OCI Vaults and keys for customer-managed encryption foundations.

## What It Creates

- `oci_kms_vault`
- `oci_kms_key`

## Key Inputs

- `enable_vault`
- `enable_default_vault`
- `default_vault_type`
- `enable_default_key`
- `vaults`
- `keys`

## Outputs

- `vault_ids`
- `vault_names`
- `vault_management_endpoints`
- `key_ids`

## Usage Notes

- Vault and key choices are ownership-sensitive and disabled by default in generic blueprints.
- Use explicit maps when an environment needs more than the default vault/key shape.

## Contract

The module follows the repository module contract for `tenancy_ocid`, `compartment_ocid`, `region`, `org`, `environment`, `region_key`, `cis_level`, `defined_tags`, and `freeform_tags` where those inputs apply.
