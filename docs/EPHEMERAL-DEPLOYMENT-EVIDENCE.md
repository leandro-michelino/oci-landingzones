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
| `blueprints/devops/oci-devops-pipeline` | Sao Paulo | Apply/destroy | Created and destroyed DevOps project, repository, build pipeline, deploy pipeline, and topic. |
| `blueprints/devops/oci-devops-pipeline` | Vinhedo | Apply/destroy | Created and destroyed DevOps project, repository, build pipeline, deploy pipeline, and topic. |
| `blueprints/extensions/streaming` | Sao Paulo | Apply/destroy | Created and destroyed stream pool and stream. |
| `blueprints/extensions/streaming` | Vinhedo | Apply/destroy | Created and destroyed stream pool and stream. |
| `blueprints/extensions/event-driven-platform` | Sao Paulo | Apply/destroy | Created and destroyed archive bucket, stream pool, stream, and topic after fixing pool-backed streams. |
| `blueprints/extensions/event-driven-platform` | Vinhedo | Apply/destroy | Created and destroyed archive bucket, stream pool, stream, and topic after fixing pool-backed streams. |
| `blueprints/extensions/observability` | Sao Paulo | Apply/destroy | Created and destroyed an APM free-tier domain. |
| `blueprints/extensions/observability` | Vinhedo | Apply/cleanup | Created an APM free-tier domain; interrupted local state was cleaned up directly and verified as deleted. |

## Evidence README Standard

Each new local evidence folder should include a `README.md` with:

- Blueprint path.
- Region and run ID.
- Deployment mode.
- Resource mode.
- Result.
- Evidence files.
- Cleanup status.
