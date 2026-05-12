# Network Appliance Module

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This Terraform module creates optional NVA compute instances and reserved private IP route targets.

## What It Creates

- `oci_core_instance`
- `oci_core_private_ip`

## Key Inputs

- `enable_net_appliance`
- `appliances`
- `enable_reserved_route_ips`
- `reserved_route_ips`
- `existing_route_target_private_ip_ids`

## Outputs

- `appliance_instance_ids`
- `appliance_private_ips`
- `route_target_private_ip_ids`

## Usage Notes

- Vendor licenses, images, and bootstrap data must stay out of committed files.
- Instances are created with source/destination check skipped for appliance routing.

## Contract

The module follows the repository module contract for `tenancy_ocid`, `compartment_ocid`, `region`, `org`, `environment`, `region_key`, `cis_level`, `defined_tags`, and `freeform_tags` where those inputs apply.
