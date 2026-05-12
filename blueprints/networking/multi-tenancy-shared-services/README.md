# Multi-Tenancy Shared Services

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this deployment when a central shared-services network supports multiple teams,
entities, or workload compartments.

## What It Does

This blueprint builds a shared-services network for many tenants, teams, or operating
entities. It separates common services like DNS, monitoring, admin access, and security
tooling from tenant workloads while making allowed cross-tenant flows explicit.

## Why Use It

Use this when many teams share common platform services but still need boundaries. It is
the shared-services model with isolation drawn clearly enough that people stop arguing
about who can talk to what.

## When To Use It

- Several tenants or operating entities share one platform.
- DNS, monitoring, admin access, or security tooling is centralized.
- Cross-tenant access must be explicit, not accidental.

## Pattern

- Shared-services VCN.
- Optional hub VCN and DRG.
- Multiple tenant or operating-entity spokes.
- Centralized DNS, security, logging, and administrative access.
- Route isolation between tenants unless explicitly allowed.

## Best Fit

- Holding companies or multi-entity organizations.
- Platform teams serving many application teams.
- Shared services such as DNS, monitoring, patching, or admin access.
- Environments requiring tenant isolation.

## Inputs To Decide

- Tenant or operating entity list.
- Shared services required by all tenants.
- Isolation boundaries.
- Allowed cross-tenant flows.
- DNS and logging model.
- Chargeback or tagging model.

## Deployment Flow

1. Deploy `blueprints/core`.
2. Complete the architecture diagram with tenant boundaries.
3. Confirm shared-service ownership.
4. Populate local tfvars.
5. Run Terraform validation and plan.
6. Apply after isolation and shared-access rules are reviewed.

## Architecture Artifacts

- Source diagram: `architecture/multi-tenancy-shared-services.excalidraw`
- Exported image: `architecture/multi-tenancy-shared-services.png`

## Notes

Tenant isolation should be visible in both the diagram and policy model.
