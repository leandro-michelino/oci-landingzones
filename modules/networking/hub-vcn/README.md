# Hub VCN Module

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This Terraform module creates a hub VCN with optional gateways, security lists, route tables, and subnets.

## What It Creates

- `oci_core_vcn`
- `oci_core_internet_gateway`
- `oci_core_nat_gateway`
- `oci_core_service_gateway`
- `oci_core_security_list`
- `oci_core_route_table`
- `oci_core_subnet`

## Key Inputs

- `vcn_cidr_blocks`
- `vcn_dns_label`
- `enable_internet_gateway`
- `enable_nat_gateway`
- `enable_service_gateway`
- `route_tables`
- `security_lists`
- `subnets`

## Outputs

- `vcn_id`
- `subnet_ids`
- `route_table_ids`
- `security_list_ids`
- `gateway_ids`

## Usage Notes

- Use this module for centralized routing and shared network services.
- Route rules can resolve gateway keys and caller-provided network entity IDs.

## Contract

The module follows the repository module contract for `tenancy_ocid`, `compartment_ocid`, `region`, `org`, `environment`, `region_key`, `cis_level`, `defined_tags`, and `freeform_tags` where those inputs apply.
