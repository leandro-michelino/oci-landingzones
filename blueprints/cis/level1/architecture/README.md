# CIS Level 1 Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

CIS Level 1 wraps the core landing-zone baseline with practical governance, monitoring, logging, and security-control defaults while keeping exception handling explicit.

Keep architecture notes in this folder. Add rendered artifacts only when a review package needs them.

## ASCII Architecture

```text
OCI Tenancy
+-- Core Landing Zone Baseline
|   +-- Compartments, IAM groups, dynamic groups, policies
|   +-- Tag namespace, tag defaults, budgets, events
|   +-- Logging, monitoring, Cloud Guard, Vault, VSS
|
+-- CIS Level 1 Control Scope
|   +-- Enabled guardrails and evidence collection
|   +-- Security Zone recipe optional by target compartment
|   +-- Exception register for accepted deviations
|
+-- Operators and Auditors
    +-- Platform admins use least-privilege groups
    +-- Auditors consume logs, alarms, and reports
```

## Why This Diagram Matters

The diagram is the quick sanity check before anyone opens Terraform. It should make
traffic paths, ownership boundaries, dependencies, and operational hand-offs obvious
enough that a customer, network engineer, security reviewer, and platform engineer can
point at the same picture and agree on what is being built.

## Review Checklist

- Confirm the compartment, region, and ownership boundary shown here matches the tfvars.
- Confirm all external dependencies are named before `terraform plan`.
- Confirm ingress, egress, inspection, DNS, and private service paths are intentional.
- Confirm logging, monitoring, IAM, and break-glass responsibilities are represented.
- Keep rendered diagrams outside the blueprint unless they become the approved artifact.

## When To Update It

- The blueprint adds or removes a major resource type.
- A route, trust boundary, region, compartment, or access path changes.
- A customer-specific assumption becomes part of the reusable pattern.
- The README explains a behavior that is not visible in the diagram yet.
