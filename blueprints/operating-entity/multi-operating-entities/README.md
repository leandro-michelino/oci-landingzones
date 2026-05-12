# Multi-Operating-Entities Landing Zone

This blueprint is for customers that need repeatable onboarding for multiple business
units, subsidiaries, agencies, or major application portfolios.

## What It Does

This blueprint repeats the operating-entity pattern for many business units,
subsidiaries, agencies, or portfolios. It keeps delegated admins, budgets, policies,
tags, logging, shared services, and network boundaries consistent without flattening
everyone into one cloud bucket.

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

## Expected Composition

- Core landing zone outputs.
- Repeated operating entity compartments.
- Entity IAM groups and policies.
- Optional entity spokes or private endpoints.
- Budget, logging, and event rules by entity.
- Shared-services network attachment.

## Deployment Notes

Use this after the core blueprint. Pair it with a hub-spoke, shared-services, or
externally managed VCN pattern depending on the customer network model.
