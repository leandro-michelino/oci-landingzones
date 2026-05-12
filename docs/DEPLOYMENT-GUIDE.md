# Deployment Guide

This guide describes the intended deployment sequence. Some Terraform resources
are implemented and others remain planned; use this as the project execution
map.

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

Each deployable blueprint folder should be readable on its own. Review the local
`README.md` and `architecture/README.md` before planning or applying that
blueprint.

Use `docs/DEPLOYMENT-PATTERN-CATALOG.md` as the selection menu before choosing
a blueprint. The catalog includes core, CIS, identity, operating entity,
networking, compliance, data platform, industry, and extension patterns.

## Phase 1 - Core Structure

Deploy the core blueprint first. The implemented foundation creates the landing
zone compartment structure and baseline governance tagging required by later
blueprints.

Required diagram:

```text
docs/architecture/diagrams/01-iam-compartments.excalidraw
```

For ephemeral tests, set `parent_compartment_ocid` in a local ignored
`terraform.tfvars` file. Do not commit real tenancy or compartment OCIDs.
Set `home_region` to the tenancy home region for Identity operations when it
differs from the workload `region`.

OCI Identity tag deletes are asynchronous and can take several minutes per tag
definition after Terraform removes tag defaults. For fast ephemeral tests that
do not need defined tags, set `enable_tagging = false`. For tests that need tag
definitions but not tag defaults, set `enable_tag_defaults = false`.

Expected module order:

1. `iam/compartments`
2. `governance/tagging`

## Phase 2 - IAM Foundation

The core IAM foundation creates landing zone administrator, network
administrator, security administrator, governance administrator, workload
administrator, and auditor groups. Default policies are scoped to the generated
landing zone compartment paths and can be overridden or extended with
`iam_policies`.

Tenancies with many existing groups or dynamic groups may hit OCI Identity
service limits during test deployments. In those cases, disable only the
quota-constrained defaults in local ignored test variable files:
`enable_default_iam_groups = false`,
`enable_default_dynamic_groups = false`, or
`enable_default_iam_policies = false`.

Implemented module order:

1. `iam/groups`
2. `iam/dynamic-groups`
3. `iam/policies`

Planned core modules after the IAM foundation:

1. `security/vault`
2. `security/cloud-guard`
3. `security/security-zones`
4. `governance/logging`
5. `governance/events`
6. `governance/budgets`
7. `operations/monitoring`

## Phase 3 - Networking

Choose one networking blueprint and deploy it after core.
Each networking deployment folder has a local README and `architecture/` folder
with the expected editable diagram and exported image names.

Standalone VCN blueprints require:

```text
docs/architecture/diagrams/03-standalone-vcn.excalidraw
```

Hub-spoke blueprints require the matching `02-hub-spoke-*.excalidraw` diagram.

## Phase 4 - Operating Entities

Use `blueprints/operating-entity/` to onboard each business unit, subsidiary, or
workload team.

Required diagram:

```text
docs/architecture/diagrams/06-operating-entity.excalidraw
```

## Phase 5 - Extensions

Deploy extensions only after core and the required networking foundation exist.
Each extension must include its own architecture diagram.

## Specialized Patterns

Some deployments are cross-cutting and should be selected based on the customer
operating model rather than a simple phase number:

- Use operating entity patterns for delegated ownership and repeatable
  application-team onboarding.
- Use compliance patterns for Zero Trust, SCCA-style, or regulator-driven
  control sets.
- Use data platform and industry patterns when workload behavior needs its own
  landing zone conventions.
- Use multicloud and regional hub patterns when routing, inspection, or
  connectivity boundaries drive the architecture.
