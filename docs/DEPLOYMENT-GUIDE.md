# Deployment Guide

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This guide describes the intended deployment sequence. Some Terraform resources
are implemented and others remain planned; use this as the project execution
map.

## Phase 0 - Bootstrap

Bootstrap verifies local prerequisites and records the manual decisions needed
before a real `terraform apply`: OCI CLI access, tenancy context, remote state,
and secrets handling. Remote state provisioning remains a manual or
customer-specific step until the backend contract is finalized.

```bash
bash scripts/bootstrap.sh --org acme --env prod --region eu-frankfurt-1
oci iam tenancy get --tenancy-id "$TENANCY_OCID"
pre-commit install
```

`scripts/bootstrap.sh` delegates to `ansible/playbooks/bootstrap.yml` when
Ansible is available. The shell fallback only validates arguments and prints
the prerequisite checklist.

Local validation can create `.terraform/`, `.terraform.lock.hcl`, plans, and
state files in many blueprint folders. They are intentionally ignored and should
be removed from the workspace before committing.

Use the Ansible-backed validation entry point before commits:

```bash
./scripts/validate-all.sh
```

This auto-discovers implemented Terraform blueprints in the Phase 1-5 families
only, validates them without a remote backend, runs Ansible syntax checks, and
cleans generated Terraform artifacts even when a validation step fails. The
Ansible role uses a local Terraform plugin cache and a bounded timeout per
Terraform command so repeated checks stay predictable.

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
blueprints/core/architecture/core.excalidraw
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
3. `governance/logging`

Core creates audit, network, service, and security log groups by default in the
governance compartment. VCN flow logs, Object Storage logs, Load Balancer logs,
and other service logs are wired through `vcn_flow_logs` and `service_logs`
once the source resource OCIDs exist. Generic core keeps tenancy audit retention
opt-in because it is a tenancy-wide setting; CIS wrappers enable it by default.

Cloud Guard is also wired through core. Generic core keeps it disabled by
default because it manages tenancy-wide service configuration. CIS Level 1 and
Level 2 enable Cloud Guard by default and create a target for the landing zone
root compartment. Attach approved detector and responder recipes through
`cloud_guard_detector_recipe_ids` and `cloud_guard_responder_recipe_ids`.

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
2. `security/security-zones`
3. `governance/events`
4. `governance/budgets`
5. `operations/monitoring`

## Phase 3 - Networking

Choose one networking blueprint and deploy it after core.
Each networking deployment folder has a local README and `architecture/` folder
with the expected editable diagram and exported image names.

Each networking blueprint keeps its own diagram in its local `architecture/`
folder, for example `architecture/standalone-three-tier-vcn-defaults.excalidraw`
or `architecture/hub-spoke-with-drg-and-three-tier-vcns.excalidraw`.

## Phase 4 - Operating Entities

Use operating entity blueprints when the main question is ownership: who can
administer the environment, where workloads live, and how access stays scoped.

Available Phase 4 blueprints:

- `blueprints/operating-entity/` creates one operating entity root compartment,
  child workload compartments, admin and auditor groups, and scoped IAM policies.
- `blueprints/operating-entity/multi-operating-entities/` repeats that pattern
  for several business units, subsidiaries, agencies, or major portfolios.
- `blueprints/operating-entity/workload-vending/` vends a standard app-team
  package with workload compartments, admin/operator/auditor groups, and scoped
  manage/use/read policies.

These blueprints are intentionally focused on compartments, delegated IAM, and
ownership metadata first. Budgets, logging, events, quotas, and network
attachments are the next governance/security layers, so keep those assumptions
visible in the local README and architecture notes.

Required diagram:

```text
blueprints/operating-entity/architecture/operating-entity.excalidraw
blueprints/operating-entity/multi-operating-entities/architecture/multi-operating-entities.excalidraw
blueprints/operating-entity/workload-vending/architecture/workload-vending.excalidraw
```

## Phase 1-5 Wiring Check

| Phase | Terraform Entry Points | Ansible Coverage |
|---|---|---|
| Phase 1 - Core | `blueprints/core/` | `validate.yml` runs fmt/init/validate and cleanup through Ansible. |
| Phase 2 - IAM | Reusable IAM modules composed by `blueprints/core/` and CIS wrappers | Covered through core, CIS Level 1, and CIS Level 2 validation. |
| Phase 3 - Networking | All implemented folders under `blueprints/networking/` | Each implemented networking blueprint is initialized and validated without backend. |
| Phase 4 - Operating entities | `blueprints/operating-entity/` and child onboarding patterns | Single entity, multi-entity, and workload vending are initialized and validated without backend. |
| Phase 5 - Extensions | `blueprints/extensions/oke`, `apigw`, `streaming`, `waf`, and `exadata` | Each extension blueprint is initialized and validated without backend. |

Planned identity, compliance, data platform, disaster recovery, and industry
folders are documented in the catalog but are excluded from automated Terraform
validation until they become part of the implemented phase surface.

## Phase 5 - Extensions

Deploy extensions only after core and the required networking foundation exist.
Each extension must include its own architecture diagram.

Implemented Phase 5 extension entry points:

- `blueprints/extensions/oke/` creates an optional OKE cluster and optional node
  pool. Both are disabled by default.
- `blueprints/extensions/apigw/` creates an optional API Gateway and optional
  deployment with routes. Both are disabled by default.
- `blueprints/extensions/streaming/` creates an optional stream pool and streams.
  Creation is disabled by default.
- `blueprints/extensions/waf/` creates an optional WAF policy and optional web
  application firewall attachment to a load balancer. Both are disabled by
  default.
- `blueprints/extensions/exadata/` creates optional Exadata Cloud Infrastructure.
  Creation is disabled by default because it is high-cost and quota-sensitive.

Keep real subnet, VCN, load balancer, availability domain, image, and SSH values
in local ignored tfvars files. The committed examples show the shape only.

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
