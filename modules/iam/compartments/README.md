# Compartments Module

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This Terraform module creates the root landing-zone compartment and child compartments used by downstream blueprints.

## What It Creates

- `oci_identity_compartment`

## Key Inputs

- `compartment_ocid`
- `root_compartment_name`
- `root_compartment_description`
- `child_compartments`
- `enable_delete`

## Outputs

- `root_compartment_id`
- `child_compartment_ids`
- `compartment_ids`
- `compartment_names`

## Usage Notes

- Create compartments before tag defaults and policies that reference compartment paths.
- Use `enable_delete` carefully in real tenancies.

## Contract

The module follows the repository module contract for `tenancy_ocid`, `compartment_ocid`, `region`, `org`, `environment`, `region_key`, `cis_level`, `defined_tags`, and `freeform_tags` where those inputs apply.
