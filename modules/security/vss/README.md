# Vulnerability Scanning Module

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This Terraform module creates VSS host and container scan recipes and targets.

## What It Creates

- `oci_vulnerability_scanning_host_scan_recipe`
- `oci_vulnerability_scanning_host_scan_target`
- `oci_vulnerability_scanning_container_scan_recipe`
- `oci_vulnerability_scanning_container_scan_target`

## Key Inputs

- `enable_vss`
- `enable_default_host_scan`
- `host_scan_recipes`
- `host_scan_targets`
- `container_scan_recipes`
- `container_scan_targets`

## Outputs

- `host_scan_recipe_ids`
- `host_scan_target_ids`
- `container_scan_recipe_ids`
- `container_scan_target_ids`

## Usage Notes

- Scan targets should be approved per environment.
- Default host scan can target the workload compartment when enabled.

## Contract

The module follows the repository module contract for `tenancy_ocid`, `compartment_ocid`, `region`, `org`, `environment`, `region_key`, `cis_level`, `defined_tags`, and `freeform_tags` where those inputs apply.
