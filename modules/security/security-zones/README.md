# Security Zones Module

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This Terraform module creates Security Zones using a supplied or looked-up recipe.

## What It Creates

- `oci_cloud_guard_security_recipes`
- `oci_cloud_guard_security_zone`

## Key Inputs

- `enable_security_zones`
- `enable_default_security_zone`
- `default_security_zone_target_ocid`
- `default_security_zone_recipe_id`
- `security_zones`

## Outputs

- `security_zone_ids`
- `security_zone_names`
- `security_zone_target_ids`
- `security_zone_recipe_ids`

## Usage Notes

- Security Zones enforce hard guardrails on protected compartments.
- Confirm recipes and target scope before enabling.

## Contract

The module follows the repository module contract for `tenancy_ocid`, `compartment_ocid`, `region`, `org`, `environment`, `region_key`, `cis_level`, `defined_tags`, and `freeform_tags` where those inputs apply.
