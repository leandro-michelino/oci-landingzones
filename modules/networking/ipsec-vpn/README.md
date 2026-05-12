# IPSec VPN Module

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This Terraform module creates a CPE and IPSec connection when VPN is enabled.

## What It Creates

- `oci_core_cpe`
- `oci_core_ipsec`

## Key Inputs

- `enable_ipsec`
- `drg_id`
- `cpe_ip_address`
- `cpe_is_private`
- `static_routes`

## Outputs

- `ipsec_id`
- `cpe_id`

## Usage Notes

- VPN resources require valid customer edge and route details.
- Keep disabled for smoke tests that only validate topology.

## Contract

The module follows the repository module contract for `tenancy_ocid`, `compartment_ocid`, `region`, `org`, `environment`, `region_key`, `cis_level`, `defined_tags`, and `freeform_tags` where those inputs apply.
