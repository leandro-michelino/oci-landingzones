# Tagging Module

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This Terraform module creates a tag namespace, tag definitions, and optional tag defaults for the landing zone.

## What It Creates

- `oci_identity_tag_namespace`
- `oci_identity_tag`
- `oci_identity_tag_default`

## Key Inputs

- `enable_tagging`
- `enable_tag_defaults`
- `tag_namespace_name`
- `tag_definitions`
- `tag_default_compartment_ids`
- `tag_default_values`

## Outputs

- `tag_namespace_id`
- `tag_definition_ids`
- `tag_default_ids`

## Usage Notes

- Tag deletes can be slow because OCI retires and deletes tag definitions asynchronously.
- Use tag defaults only when the target compartments and values are approved.

## Contract

The module follows the repository module contract for `tenancy_ocid`, `compartment_ocid`, `region`, `org`, `environment`, `region_key`, `cis_level`, `defined_tags`, and `freeform_tags` where those inputs apply.
