# Azure + OCI Identity Federation Blueprint Draft

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This document defines a concrete blueprint draft for federating Microsoft Entra
ID with OCI IAM so enterprise users and groups authenticate centrally while OCI
authorization remains explicit and auditable.

## Deployment Purpose

Establish single sign-on from Microsoft Entra ID into OCI Console and API
surfaces, map Entra groups to OCI groups, and enforce least-privilege
authorization using OCI policies.

## Primary Outcomes

- Central identity lifecycle in Entra ID.
- OCI access by federated users without local OCI passwords.
- Deterministic mapping between Entra groups and OCI groups.
- Standard break-glass pattern for tenancy administration.
- Audit trail coverage across Entra sign-ins and OCI activity.

## Architecture At A Glance

| Item | Details |
| --- | --- |
| Identity source | Microsoft Entra ID |
| Federation protocol | SAML 2.0 (OIDC can be evaluated for app-specific paths) |
| OCI target | OCI IAM federation and OCI groups/policies |
| Access model | Group-based RBAC with conditional access guardrails |
| Trust boundary | Entra tenant trust and OCI tenancy trust remain separate and explicit |

## Architecture

```text
+--------------------------------------------------------------------------------------------------+
| Azure + OCI Identity Federation                                                                  |
+--------------------------------------------------------------------------------------------------+
| [Enterprise User]                                                                                |
|        |                                                                                         |
|        v                                                                                         |
| [Microsoft Entra ID] -- MFA + Conditional Access -- issues SAML assertion                        |
|        |                                                                                         |
|        v                                                                                         |
| [OCI IAM Identity Provider] -- maps group claims --> [OCI Groups] -- authorized by --> [Policies]|
|        |                                                                                         |
|        +--> OCI Console                                                                          |
|        `--> OCI API / CLI (federated session tokens)                                             |
|                                                                                                  |
| [Break-glass OCI local admins] kept isolated, monitored, and approval-gated                      |
+--------------------------------------------------------------------------------------------------+
```

## Control Design

### Authentication

- Entra ID is the primary authenticator.
- MFA is mandatory for privileged OCI roles.
- Conditional Access blocks risky sessions and unmanaged devices for admin roles.

### Authorization

- Entra groups map one-to-one to OCI groups where possible.
- OCI policies remain the source of truth for tenancy permissions.
- No wildcard policy grants for federated admin groups.

### Session And Access Hygiene

- Enforce short session duration for privileged profiles.
- Restrict legacy auth paths.
- Keep a minimal local OCI admin group for emergency access only.

## Suggested Role Mapping

| Entra Group | OCI Group | Intended Scope |
| --- | --- | --- |
| `entra-oci-platform-admin` | `oci-platform-admin` | Tenancy/platform operations with explicit change controls |
| `entra-oci-security-admin` | `oci-security-admin` | Cloud Guard, Vault, security services, policy review |
| `entra-oci-network-admin` | `oci-network-admin` | VCN, DRG, gateways, routing, DNS administration |
| `entra-oci-app-operators` | `oci-app-operators` | Compartment-level day-2 app operations |
| `entra-oci-readonly` | `oci-readonly` | Audit and read-only troubleshooting |

## Inputs To Settle Before Build

- Entra tenant ID and identity owner.
- OCI tenancy OCID and target identity domain strategy.
- Group naming standards in both clouds.
- High-privilege role definitions and approval path.
- Break-glass account policy and rotation workflow.
- Compliance requirements for sign-in logs and retention.

## Output Contract

The deployable blueprint should return:

```text
federation_provider_id
federated_group_mapping
oci_group_ids
oci_policy_ids
break_glass_group_id
audit_log_integration_notes
```

## Rollout Plan

1. Baseline:
Create IdP federation and a read-only group mapping. Validate login and claim mapping.
2. Privileged onboarding:
Enable network/security/platform admin mappings with strict policy boundaries.
3. Enforcement:
Apply Conditional Access hardening and remove legacy direct access paths.
4. Operations:
Add periodic access recertification, break-glass drills, and sign-in analytics review.

## Validation Checklist

- Federated login works for each mapped role.
- Group claims map exactly to expected OCI groups.
- Denied-path tests confirm least privilege is effective.
- Break-glass access is isolated and monitored.
- Audit events are queryable across Entra and OCI logs.

## Promotion Criteria To Deployable Blueprint

Promote to `blueprints/identity/azure-entra-federation/` when:

- Ownership is assigned for Entra and OCI IAM changes.
- Group and policy contracts are frozen.
- Security approval exists for conditional access and break-glass flow.
- Customer runbook requirements are documented.
