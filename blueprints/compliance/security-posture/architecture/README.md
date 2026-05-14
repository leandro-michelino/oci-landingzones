# Security Posture Automation Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

## Deployment Purpose

This blueprint extends the compliance baseline with automated security posture
coverage. It connects Cloud Guard target wiring, Vulnerability Scanning,
Events-based response paths, report archives, alarms, and IAM policy hand-offs.

## Architecture At A Glance

| Layer | Components |
| --- | --- |
| Detection | Cloud Guard target with detector and responder recipe attachments. |
| Scanning | Vulnerability Scanning host recipe and target. |
| Response | Events rules with ONS, Functions, or Streaming actions. |
| Evidence | Object Storage report bucket and Monitoring alarm outputs. |
| Governance | IAM statements for security admins, responders, scanners, and auditors. |

## ASCII Architecture

```text
+--------------------------------------------------------------------------------+
|                     Security Posture Automation Blueprint                       |
+--------------------------------------------------------------------------------+
|                                                                                |
|  Protected Compartment / Resource Scope                                        |
|      |                                                                         |
|      +--> Cloud Guard Target                                                   |
|      |       |                                                                 |
|      |       +--> Detector recipes                                             |
|      |       +--> Responder recipes                                            |
|      |       `--> Problems and findings                                        |
|      |                                                                         |
|      +--> Vulnerability Scanning                                               |
|      |       |                                                                 |
|      |       +--> Host scan recipe                                             |
|      |       +--> Host scan target                                             |
|      |       `--> Scheduled scan results                                       |
|      |                                                                         |
|      v                                                                         |
|  OCI Events Rules                                                              |
|      |                                                                         |
|      +--> ONS topic for notify-only flows                                      |
|      +--> Functions for reviewed auto-remediation                              |
|      `--> Streaming for downstream security pipelines                          |
|                                                                                |
|  Evidence And Operations                                                       |
|      |                                                                         |
|      +--> Object Storage report bucket                                         |
|      +--> Monitoring alarms                                                    |
|      +--> Tags and ownership metadata                                          |
|      `--> IAM policies for admin / responder / auditor roles                   |
+--------------------------------------------------------------------------------+
```

## Terraform Components

| File | Purpose |
| --- | --- |
| `main.tf` | Creates report bucket, topic, Cloud Guard target, VSS host scan resources, event rules, alarms, and IAM policy. |
| `variables.tf` | Defines scope, recipes, scanner cadence, event action, alarm, and policy inputs. |
| `outputs.tf` | Exposes target, scanner, bucket, rule, alarm, and policy outputs. |
| `terraform.tfvars.example` | Provides safe disabled defaults and placeholder OCIDs. |

## Request And Deployment Flow

1. Security owner chooses protected scope and detector/responder recipes.
2. Platform owner confirms host scan cadence and target compartments.
3. Response owner decides notification, function, or stream actions.
4. Terraform creates report storage and security automation resources.
5. Findings flow from Cloud Guard or VSS into Events and alarm destinations.
6. Auditors use report bucket and outputs as evidence hand-offs.

## Traffic And Trust Boundaries

- Cloud Guard and VSS scopes should be compartment-bounded unless tenancy-wide
  coverage is explicitly approved.
- Auto-remediation Functions must have scoped IAM and should start in notify-only
  review mode for production environments.
- Report buckets can hold sensitive findings and should not be public.
- Event actions should route to owned topics, streams, or functions.
- IAM policies should avoid broad tenancy administrator grants.

## Detailed Architecture Notes

- Cloud Guard target creation is optional so customers can attach to an existing baseline.
- Detector and responder recipes are supplied as OCIDs because many customers
  use Oracle-managed or centrally managed recipes.
- Host scan recipe and target are split to support reused recipes across scopes.
- Event rules are generic enough to handle Cloud Guard, VSS, Audit, or resource events.
- Alarms use a map so each customer can wire the metrics available in their region.
- The report bucket is versioned by default for evidence preservation.

## Operational Boundaries

- Terraform does not author Cloud Guard detector rule logic.
- Terraform does not implement remediation function code.
- Scan exceptions and false-positive tuning stay with security operations.
- Evidence retention policy must be aligned with legal and audit requirements.
- Automatic responders require a separate change-management approval.

## Review Checklist

- Protected scope is correct and not broader than intended.
- Detector and responder recipe OCIDs are approved.
- Host scan cadence and target compartments are reviewed.
- Event actions are notify-only or remediation-approved.
- Report bucket retention and access are documented.
- IAM policy statements are least-privilege.
- Terraform plan is reviewed by security and platform owners.
