# OpenSearch Search And Vector Platform

Use this page as the operator guide for `blueprints/data-platform/opensearch`.
It tells you what the blueprint builds, which inputs deserve a real review, how
to run Terraform or the local Ansible wrappers, and where to find the detailed
Architecture design.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/data-platform/opensearch` |
| Best fit | Managed OpenSearch cluster for search and vector index workloads. |
| Terraform shape | Optional private VCN/subnet/NSG, `oci_opensearch_opensearch_cluster.this`, optional snapshot bucket, optional IAM policy. |
| Inputs to settle first | Private network mode, cluster sizing, security mode, snapshot bucket, and IAM policy statements. |
| Outputs to hand off | `blueprint_name`, `name_prefix`, `resource_ids`, `private_network`, `opensearch_cluster_id`, `opensearch_endpoint`, `opendashboard_endpoint`, `snapshot_bucket_name`, `access_policy_id` |
| Local runner | `terraform plan` for quick iteration; `ansible/plan.yml` and guarded `ansible/apply.yml` for the repo-standard flow. |

## Deployment Purpose

Deploys an OCI Search with OpenSearch foundation for application search,
log-style indexing, semantic search, vector indexes, and RAG workloads. The
blueprint can consume an existing private subnet or create a small private VCN,
subnet, and NSG so the cluster is ready for controlled app-team access.

## When To Use This Deployment

- Application teams need managed OpenSearch without running search nodes.
- AI teams need a vector/search target for embedding or retrieval workflows.
- Platform teams need sizing, network placement, snapshot, and IAM decisions
  captured before apply.
- Outputs must be handed off to application, platform, or security teams.

## Use Cases

| Use Case | Why This Blueprint Fits |
| --- | --- |
| Application search service | Creates a managed OpenSearch endpoint for product, catalog, document, or operational search. |
| Vector and RAG retrieval target | Provides a search/vector platform for embedding pipelines, semantic search, and retrieval-augmented generation. |
| Log-style indexing | Supports private indexing and dashboard access for teams that need searchable operational or application events. |
| Isolated search sandbox | Can create its own small private VCN/subnet/NSG for demos, tests, and workload validation. |
| Snapshot and export foundation | Optional bucket and IAM policy settings prepare the cluster for snapshot, export, or backup workflows. |

## Deployment Modes

| Mode | Use It When | Main Inputs |
| --- | --- | --- |
| Private cluster with new network | Fastest complete deployment for demos, tests, or isolated app landing zones. | `create_private_network = true`, `vcn_cidr_block`, `subnet_cidr_block` |
| Private cluster with existing network | Production or shared environments already have approved network foundations. | `vcn_id`, `subnet_id`, `nsg_id`, `create_private_network = false` |
| Snapshot-only extension | A cluster exists and you only need an export/backup bucket and IAM policy. | `create_cluster = false`, `create_snapshot_bucket = true` |
| Validation only | You want CI or local validation without creating cost-bearing resources. | `create_cluster = false`, `create_snapshot_bucket = false` |

## Quick Start

For a complete private deployment, start with the example file and fill in the
approved compartment, sizing, and network values:

```bash
cd blueprints/data-platform/opensearch
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

For the repo-standard guarded flow:

```bash
cd blueprints/data-platform/opensearch
ansible-playbook -i localhost, -c local ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, -c local ansible/apply.yml
CONFIRM_DESTROY=true ansible-playbook -i localhost, -c local ansible/destroy.yml
```

## What This Deploys

| Resource | Enable Flag |
| --- | --- |
| Optional private VCN/subnet/NSG | `create_private_network` |
| OpenSearch cluster | `create_cluster` |
| Snapshot/export bucket | `create_snapshot_bucket` |
| IAM policy shell | `policy_statements` not empty |

## Inputs To Decide

| Input | What To Decide |
| --- | --- |
| `create_private_network`, `vcn_id`, `subnet_id`, `nsg_id` | Private network placement. |
| `master_node_*`, `data_node_*`, `opendashboard_*` | Cluster shape and cost profile. Leader and data nodes should be reviewed against the current OCI minimums. |
| `security_*` | OpenSearch security mode and admin identity. |
| `create_snapshot_bucket`, `snapshot_bucket_name`, `kms_key_id` | Snapshot/export bucket and encryption behavior. |
| `policy_statements` | Admin, writer, and read-only consumer access. |

## Deployment Order

1. Confirm whether this blueprint creates the private network or consumes an
   approved subnet and NSG.
2. Review OpenSearch version, node counts, OCPU, memory, and storage sizing.
3. Decide whether a snapshot/export bucket and IAM policy are part of day one.
4. Populate `terraform.tfvars` with real values from approved sources.
5. Run plan and review endpoints, private IPs, and IAM scope.
6. Apply only after the platform, application, or AI owner approves the output
   shape.

## Outputs

| Output | Meaning |
| --- | --- |
| `private_network` | Optional VCN, subnet, and NSG OCIDs created by this blueprint. |
| `opensearch_cluster_id` | OpenSearch cluster OCID. |
| `opensearch_endpoint` | Search endpoint FQDN. |
| `opendashboard_endpoint` | Dashboard endpoint FQDN. |
| `snapshot_bucket_name` | Snapshot/export bucket name. |
| `access_policy_id` | IAM policy OCID. |

## Architecture

The full detailed Architecture is local to this deployment:

```text
architecture/README.md
```

## Review Before Apply

- Confirm OpenSearch version, node counts, OCPU, memory, and storage values.
- Confirm private subnet, NSG, and optional created network CIDRs.
- Confirm security mode, master user handling, and any secret hand-off process.
- Confirm snapshot bucket naming, KMS behavior, and retention/export ownership.
- Confirm IAM policy statements are scoped to approved admin, writer, and reader groups.
- Confirm no generated Terraform files, state files, plans, or local tfvars are committed.

## Validation

```bash
terraform fmt -check
terraform init -backend=false
terraform validate
ansible-playbook -i localhost, -c local ansible/plan.yml
```
