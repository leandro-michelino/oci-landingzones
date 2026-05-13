# Bastion Module

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This Terraform module creates an OCI Bastion target for private administrative access.

## What It Creates

- `oci_bastion_bastion`

## Key Inputs

- `enable_bastion`
- `target_subnet_id`
- `bastion_type`
- `client_cidr_block_allow_list`
- `max_session_ttl_in_seconds`

## Outputs

- `bastion_id`
- `private_endpoint_ip_address`

## Usage Notes

- Bastion is disabled unless explicitly enabled.
- `target_subnet_id` and a non-empty `client_cidr_block_allow_list` are required
  when Bastion is enabled.
- World-open client CIDRs (`0.0.0.0/0` and `::/0`) are rejected. Use approved
  administrator source CIDRs and review TTL values before production use.

## Contract

The module follows the repository module contract for `tenancy_ocid`, `compartment_ocid`, `region`, `org`, `environment`, `region_key`, `cis_level`, `defined_tags`, and `freeform_tags` where those inputs apply.
