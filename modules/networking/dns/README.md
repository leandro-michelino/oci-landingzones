# Private DNS Module

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This Terraform module creates private DNS views, zones, resolver attachments, and optional resolver endpoints.

## What It Creates

- `oci_dns_view`
- `oci_dns_zone`
- `oci_dns_resolver`
- `oci_dns_resolver_endpoint`

## Key Inputs

- `enable_private_dns`
- `dns_label`
- `private_zones`
- `vcn_ids`
- `attach_private_view_to_vcn_resolvers`
- `resolver_endpoints`

## Outputs

- `private_view_id`
- `private_zone_ids`
- `vcn_resolver_ids`
- `resolver_endpoint_ids`

## Usage Notes

- Resolver endpoints can introduce network dependencies and should stay opt-in.
- Use this module when hub-spoke or shared-services designs need split-horizon DNS.

## Contract

The module follows the repository module contract for `tenancy_ocid`, `compartment_ocid`, `region`, `org`, `environment`, `region_key`, `cis_level`, `defined_tags`, and `freeform_tags` where those inputs apply.
