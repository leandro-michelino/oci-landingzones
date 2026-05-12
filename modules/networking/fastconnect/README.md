# FastConnect Module

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This Terraform module creates an OCI FastConnect virtual circuit when enabled.

## What It Creates

- `oci_core_virtual_circuit`

## Key Inputs

- `enable_fastconnect`
- `virtual_circuit_type`
- `bandwidth_shape_name`
- `drg_id`
- `customer_bgp_asn`
- `provider_service_id`

## Outputs

- `virtual_circuit_id`
- `virtual_circuit_state`
- `provider_state`

## Usage Notes

- FastConnect can depend on external provider coordination and cost-sensitive resources.
- Keep disabled for local validation unless provider details are approved.

## Contract

The module follows the repository module contract for `tenancy_ocid`, `compartment_ocid`, `region`, `org`, `environment`, `region_key`, `cis_level`, `defined_tags`, and `freeform_tags` where those inputs apply.
