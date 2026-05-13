# Custom Identity Domain

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this deployment when the customer already has an OCI Identity Domain or an external
identity provider that the landing zone must integrate with.

## What It Does

This blueprint connects the landing zone to identity that already exists. It keeps group
mappings, federation ownership, policy bindings, break-glass handling, and external IdP
assumptions visible so Terraform plugs into the customer model instead of taking it
over.

## Why Use It

Use this when the customer already has an identity model and the landing zone needs to
plug into it instead of inventing a new one. This is the respectful brownfield option.

## When To Use It

- There is an existing OCI identity domain or corporate IdP.
- Group names and federation rules are already owned by another team.
- Terraform should bind policy and access, not rebuild identity from scratch.

## Pattern

- Existing identity domain integration.
- Group mapping for platform, security, networking, and workload roles.
- Optional federation notes for external identity providers.
- IAM policy bindings to existing groups.

## Best Fit

- Brownfield tenancies.
- Enterprise identity integration.
- Customers with existing SSO and lifecycle-management processes.

## Inputs To Decide

- Existing identity domain OCID or name.
- External IdP details.
- Group mapping.
- Federation ownership.
- SCIM or manual group lifecycle.
- Break-glass account handling.

## Deployment Flow

1. Inventory existing identity domains and groups.
2. Complete the architecture notes with ownership boundaries.
3. Confirm group mappings with the customer identity team.
4. Populate local ignored tfvars.
5. Run Terraform validation and plan.
6. Apply after federation and policy scope are reviewed.

## Architecture Artifacts

- Architecture notes: `architecture/README.md`
