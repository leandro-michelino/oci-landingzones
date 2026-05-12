# Identity Deployment Blueprints

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This folder contains identity-specific deployment patterns for OCI landing zones. Each
child folder should be usable on its own, with local deployment notes and architecture
artifacts.

## What It Does

This is the identity pattern catalog. Use it when the main question is how OCI access
should be shaped: clean new identity boundaries, integration with an existing domain, or
a smaller CIS-style IAM baseline before the rest of the landing zone catches up.

## Why Use It

Use this folder when the main design question is who can access what, from which
identity domain, and under whose operational control.

## When To Use It

- Use CIS basic for quick hardening.
- Use custom identity domain when identity already exists.
- Use new identity domain when the project needs a clean boundary.

## Catalogue

| Pattern | Folder | Use When |
|---|---|---|
| CIS basic identity | `cis-basic/` | A minimal CIS-aligned IAM baseline is required. |
| Custom identity domain | `custom-identity-domain/` | The customer already has an identity provider or OCI Identity Domain. |
| New identity domain | `new-identity-domain/` | A dedicated OCI Identity Domain should be provisioned. |

## Folder Contract

Each deployment folder should contain:

- `README.md` with purpose, fit, inputs, and deployment flow.
- `architecture/<deployment>.excalidraw` for the editable diagram.
- `architecture/<deployment>.png` for the exported image.
- Terraform code and safe example variables.
