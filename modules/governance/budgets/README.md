# Budgets Module

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This Terraform module creates OCI Budgets and budget alert rules for landing-zone spend guardrails.

## What It Creates

- `oci_budget_budget`
- `oci_budget_alert_rule`

## Key Inputs

- `enable_budgets`
- `enable_default_budget`
- `default_budget_amount`
- `default_budget_target_ocids`
- `budgets`

## Outputs

- `budget_ids`
- `budget_names`
- `budget_alert_rule_ids`

## Usage Notes

- Budgets are disabled unless `enable_budgets` is true.
- Alert recipients and budget targets should come from environment-specific tfvars.

## Contract

The module follows the repository module contract for `tenancy_ocid`, `compartment_ocid`, `region`, `org`, `environment`, `region_key`, `cis_level`, `defined_tags`, and `freeform_tags` where those inputs apply.
