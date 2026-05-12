# Deployment Guide

This guide describes the intended deployment sequence. Terraform resources are
not implemented yet; use this as the project execution map.

## Phase 0 - Bootstrap

Bootstrap creates the remote state location, verifies OCI CLI access, and
installs local validation tooling.

```bash
bash scripts/bootstrap.sh --org acme --env prod --region eu-frankfurt-1
oci iam tenancy get --tenancy-id "$TENANCY_OCID"
pre-commit install
```

The generic landing zone deployment does not enable CIS behavior by default. To
deploy a CIS landing zone, start from one of the dedicated folders instead:

```bash
cd blueprints/cis/level1
# or
cd blueprints/cis/level2
```

## Phase 1 - Core Landing Zone

Deploy the core blueprint first. It creates the baseline compartments, IAM,
governance, and security services required by later blueprints.

Required diagram:

```text
docs/architecture/diagrams/01-iam-compartments.excalidraw
```

Expected module order:

1. `governance/tagging`
2. `iam/compartments`
3. `iam/groups`
4. `iam/dynamic-groups`
5. `iam/policies`
6. `security/vault`
7. `security/cloud-guard`
8. `security/security-zones`
9. `governance/logging`
10. `governance/events`
11. `governance/budgets`
12. `operations/monitoring`

## Phase 2 - Networking

Choose one networking blueprint and deploy it after core.

Standalone VCN blueprints require:

```text
docs/architecture/diagrams/03-standalone-vcn.excalidraw
```

Hub-spoke blueprints require the matching `02-hub-spoke-*.excalidraw` diagram.

## Phase 3 - Operating Entities

Use `blueprints/operating-entity/` to onboard each business unit, subsidiary, or
workload team.

Required diagram:

```text
docs/architecture/diagrams/06-operating-entity.excalidraw
```

## Phase 4 - Extensions

Deploy extensions only after core and the required networking foundation exist.
Each extension must include its own architecture diagram.
