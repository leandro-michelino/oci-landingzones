# Network Firewall Module

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This Terraform module creates an OCI Network Firewall policy and optional Network Firewall instance.

## What It Creates

- `oci_network_firewall_network_firewall_policy`
- `oci_network_firewall_network_firewall`

## Key Inputs

- `enable_network_firewall`
- `firewall_label`
- `subnet_id`
- `network_firewall_policy_id`
- `network_security_group_ids`

## Outputs

- `network_firewall_policy_id`
- `network_firewall_id`
- `network_firewall_private_ip`

## Usage Notes

- Firewall instances are cost-sensitive and disabled unless explicitly enabled.
- Policy rules are intentionally minimal here and should be expanded per workload.

## Contract

The module follows the repository module contract for `tenancy_ocid`, `compartment_ocid`, `region`, `org`, `environment`, `region_key`, `cis_level`, `defined_tags`, and `freeform_tags` where those inputs apply.
