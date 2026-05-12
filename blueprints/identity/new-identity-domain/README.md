# New Identity Domain

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this deployment when a landing zone needs a dedicated OCI Identity Domain for
platform teams, workloads, or a customer operating entity.

## What It Does

This blueprint creates a clean OCI Identity Domain for a new platform, program,
operating entity, or workload estate. It is where group layout, federation, admin
ownership, user lifecycle, and policy scope can be designed neatly from day one.

## Why Use It

Use this when the landing zone needs a clean identity domain for a platform, program, or
workload estate. It is useful when the customer wants separation from existing identity
sprawl.

## When To Use It

- A dedicated identity boundary is required.
- A new program, subsidiary, or platform needs isolated access administration.
- Federation and group layout can be designed cleanly from the start.

## Pattern

- New OCI Identity Domain.
- Baseline groups for platform and workload roles.
- Optional application and federation setup.
- Policy bindings for landing-zone resources.

## Best Fit

- New tenancies.
- Isolated operating entities.
- Customers separating platform identity from existing corporate domains.

## Inputs To Decide

- Identity domain name and description.
- Administrator ownership.
- Group model.
- Federation requirement.
- User lifecycle process.
- Break-glass access model.

## Deployment Flow

1. Confirm that a new identity domain is required.
2. Complete the architecture diagram.
3. Populate local ignored tfvars.
4. Run Terraform validation and plan.
5. Apply after the identity ownership model is approved.

## Architecture Artifacts

- Source diagram: `architecture/new-identity-domain.excalidraw`
- Exported image: `architecture/new-identity-domain.png`
