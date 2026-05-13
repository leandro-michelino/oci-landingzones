# OS Management Module

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This Terraform module manages OCI OS Management Hub foundations for landing zone
compute fleets. It can create managed instance groups and scheduled jobs while
keeping the same tagging and naming contract as the other modules.

## What It Creates

- OS Management Hub managed instance groups.
- OS Management Hub scheduled jobs with one or more operations.

## Key Inputs

- `tenancy_ocid`
- `compartment_ocid`
- `region`
- `org`
- `environment`
- `region_key`
- `cis_level`
- `enable_os_management`
- `managed_instance_groups`
- `scheduled_jobs`
- `defined_tags`
- `freeform_tags`

## Outputs

- `module_name`
- `name_prefix`
- `cis_level`
- `resource_ids`
- `managed_instance_group_ids`
- `scheduled_job_ids`

## Usage Notes

- Keep `enable_os_management = false` until managed instances, software sources,
  and job windows are agreed for the tenancy.
- Use `managed_instance_groups` to group fleets by OS family, architecture, or
  operational lifecycle.
- Use `scheduled_jobs` for patching, package updates, and reboot orchestration
  once maintenance windows are approved.

## Contract

The module follows the repository module contract for `tenancy_ocid`,
`compartment_ocid`, `region`, `org`, `environment`, `region_key`, `cis_level`,
`defined_tags`, and `freeform_tags` where those inputs apply.
