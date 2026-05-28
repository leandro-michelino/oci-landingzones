# Ephemeral Deployment Evidence

This note records the low-risk real deployment checks performed against the OCI
blueprints during repository validation. Raw Terraform logs and outputs are kept in
the local ignored `.leo-local/deployment-evidence/` tree because they can contain
tenant-specific OCIDs and operator metadata.

## Scope

The deployment checks use short-lived Terraform runs with unique `TestRun` tags.
Each real apply is followed by destroy or direct OCI cleanup verification.

Skipped by request:

- `blueprints/networking`
- AWS, Azure, and multicloud blueprints
- `blueprints/data-platform`
- `blueprints/ai`
- `blueprints/cis`
- `blueprints/disaster-recovery`
- `blueprints/compliance`
- `blueprints/operations`

Cost-sensitive blueprints such as Exadata are plan-only unless explicitly approved
for real deployment.

## Completed Real Runs

| Blueprint | Region | Mode | Outcome |
| --- | --- | --- | --- |
| `blueprints/devops/oci-devops-pipeline` | Sao Paulo | Apply/destroy | `ephem-20260528070009`: created and destroyed DevOps project, repository, build pipeline, deploy pipeline, and topic. |
| `blueprints/devops/oci-devops-pipeline` | Vinhedo | Apply/destroy | `ephem-20260528074413`: created and destroyed DevOps project, repository, build pipeline, deploy pipeline, and topic. |
| `blueprints/extensions/streaming` | Sao Paulo | Apply/destroy | `ephem-20260528070911`: created and destroyed stream pool and stream. |
| `blueprints/extensions/streaming` | Vinhedo | Apply/destroy | `ephem-20260528074234`: created and destroyed stream pool and stream. |
| `blueprints/extensions/event-driven-platform` | Sao Paulo | Apply/destroy | `ephem-20260528072342`: created and destroyed archive bucket, stream pool, stream, and topic after fixing pool-backed streams. |
| `blueprints/extensions/event-driven-platform` | Vinhedo | Apply/destroy | `ephem-20260528073049`: created and destroyed archive bucket, stream pool, stream, and topic after fixing pool-backed streams. |
| `blueprints/extensions/observability` | Sao Paulo | Apply/destroy | `ephem-20260528075835`: created and destroyed an APM free-tier domain. |
| `blueprints/extensions/observability` | Vinhedo | Apply/cleanup | `ephem-20260528080303`: created an APM free-tier domain; interrupted local state was cleaned up directly and verified as deleted. |

## Plan-Only Runs

| Blueprint | Region | Mode | Outcome |
| --- | --- | --- | --- |
| `blueprints/extensions/exadata` | Sao Paulo | Plan only | `plan-20260528081154`: planned one Exadata Cloud Infrastructure resource with a concrete test shape; no apply was run. |
| `blueprints/extensions/exadata` | Vinhedo | Plan only | `plan-20260528081157`: planned one Exadata Cloud Infrastructure resource with a concrete test shape; no apply was run. |
| `blueprints/extensions/exadata` | Sao Paulo | Safety plan only | `plan-20260528081238`: verified the default disabled mode plans no Exadata infrastructure resource. |
| `blueprints/extensions/exadata` | Vinhedo | Safety plan only | `plan-20260528081258`: verified the default disabled mode plans no Exadata infrastructure resource. |
| `blueprints/identity/cis-basic` | Sao Paulo | Apply blocked | `ephem-20260528081309`: planned one disposable IAM group; OCI blocked the create because IAM writes must run in the tenancy home region. No resource was created. |
| `blueprints/identity/cis-basic` | Vinhedo | Plan only | `plan-20260528081352`: planned one disposable IAM group after the Sao Paulo home-region blocker. No apply was run. |
| `blueprints/operating-entity/workload-vending` | Sao Paulo | Plan only | `plan-20260528081627`: planned one workload root, one child compartment, three groups, and scoped policies. No apply was run. |
| `blueprints/operating-entity/workload-vending` | Vinhedo | Plan only | `plan-20260528081630`: planned one workload root, one child compartment, three groups, and scoped policies. No apply was run. |

## Evidence README Standard

Each new local evidence folder should include a `README.md` with:

- Blueprint path.
- Region and run ID.
- Deployment mode.
- Resource mode.
- Result.
- Evidence files.
- Cleanup status.
