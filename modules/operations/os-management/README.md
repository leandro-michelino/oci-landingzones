# OS Management Module

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This Terraform module is a scaffold for OCI operating-system management
foundations. It keeps the repository contract and naming outputs in place, but
does not create OCI resources yet.

## What It Creates

- No OCI resources currently.

## Key Inputs

- `tenancy_ocid`
- `compartment_ocid`
- `region`
- `org`
- `environment`
- `region_key`
- `cis_level`
- `defined_tags`
- `freeform_tags`

## Outputs

- `module_name`
- `name_prefix`
- `cis_level`
- `resource_ids`

## Usage Notes

- Keep this module out of production blueprints until real OS management
  resources and lifecycle decisions are implemented.
- Use `resource_ids` as the future integration point for created resource OCIDs.

## Contract

The module follows the repository module contract for `tenancy_ocid`,
`compartment_ocid`, `region`, `org`, `environment`, `region_key`, `cis_level`,
`defined_tags`, and `freeform_tags` where those inputs apply.
