# Multi-Operating-Entities Landing Zone

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This blueprint is for customers that need repeatable onboarding for multiple business
units, subsidiaries, agencies, or major application portfolios.

## What It Does

This blueprint repeats the operating-entity pattern for many business units,
subsidiaries, agencies, or portfolios. It keeps delegated admins, auditors, scoped
policies, tags, and compartment shapes consistent without flattening everyone into one
cloud bucket.

In Phase 4 this is a deployable IAM and compartment foundation. It creates repeated
entity root compartments, each entity's child compartments, delegated groups, and
entity-scoped IAM policies. Budgets, logging, shared services, and network boundaries are
still part of the operating model, but they land in later security/governance phases.

## Why Use It

Use this when one operating entity is not enough and the platform team needs a
repeatable onboarding model. This is for organizations with several teams that all need
the same grown-up treatment.

## When To Use It

- Multiple business units or agencies share one landing zone.
- Each entity needs its own delegated admins, budgets, and policies.
- Shared services exist, but isolation still matters.

## Fit

- Several operating entities sharing one OCI foundation.
- Delegated administration per entity.
- Shared network, DNS, security, and governance services.
- Entity-level budgets, tags, and logging conventions.

## Implemented Composition

- Repeated operating entity compartments.
- Entity IAM groups and policies.
- Per-entity admin and auditor delegation.
- Per-entity compartment policy paths.
- Optional per-entity parent and policy compartment overrides.
- Defined and freeform tags for ownership and chargeback metadata.
- Documented hooks for entity spokes, shared services, budgets, logging, and event rules.

## Deployment Notes

Use this after the core blueprint. Pair it with a hub-spoke, shared-services, or
externally managed VCN pattern depending on the customer network model.

Run it when the platform team knows the operating model and wants to onboard multiple
teams in one controlled pass. For one team only, use the parent `operating-entity`
blueprint; for a repeatable app-team handoff, use `workload-vending`.

## Terraform Example

```bash
terraform init
terraform validate
terraform plan -var-file=terraform.tfvars
```
