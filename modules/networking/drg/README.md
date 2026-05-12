# DRG Module

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This Terraform module creates a Dynamic Routing Gateway and VCN attachments.

## What It Creates

- `oci_core_drg`
- `oci_core_drg_attachment`

## Key Inputs

- `drg_label`
- `drg_display_name`
- `vcn_attachments`
- `compartment_ocid`

## Outputs

- `drg_id`
- `vcn_attachment_ids`

## Usage Notes

- Route table propagation and advanced DRG route rules are handled by consuming blueprints or future module extensions.
- Attach only VCNs that belong in the same routing boundary.

## Contract

The module follows the repository module contract for `tenancy_ocid`, `compartment_ocid`, `region`, `org`, `environment`, `region_key`, `cis_level`, `defined_tags`, and `freeform_tags` where those inputs apply.
