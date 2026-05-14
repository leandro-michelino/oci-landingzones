# OpenSearch Search And Vector Platform Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

## Deployment Purpose

Provide a managed OpenSearch foundation for application search, operational
search, semantic search, and vector-backed AI workloads. The blueprint keeps
network placement, sizing, snapshot storage, and IAM in a consistent
data-platform deployment folder.

## Architecture At A Glance

| Layer | Responsibility |
| --- | --- |
| OpenSearch cluster | Search, analytics, and vector index runtime. |
| Private subnet | Network boundary for search traffic. |
| NSG | Restricts app, ingestion, and admin access. |
| Dashboard endpoint | Operator and search-admin UI. |
| Snapshot bucket | Export, backup, and vector dataset recovery staging. |
| IAM policy | Admin, writer, and reader permission hand-offs. |

## ASCII Architecture

```text
Application / RAG Pipeline / Agent
        |
        | private network + NSG
        v
OCI Search with OpenSearch
 |-- master nodes
 |-- data/search nodes
 |-- OpenDashboard nodes
 |-- vector indexes
 |-- search indexes
        |
        | snapshots / exports
        v
Object Storage Snapshot Bucket
        |
        v
Admins / Index Writers / Read-Only Consumers
```

## Terraform Components

| File | Purpose |
| --- | --- |
| `main.tf` | OpenSearch cluster, snapshot bucket, and IAM policy. |
| `variables.tf` | Network, sizing, security, snapshot, and policy inputs. |
| `outputs.tf` | Cluster, endpoint, dashboard, bucket, and policy outputs. |
| `terraform.tfvars.example` | Example network and disabled create flags. |
| `ansible/*.yml` | Standard local runners. |

## Request And Deployment Flow

1. Confirm the workload: search, logs, RAG, vectors, or mixed use.
2. Choose private subnet, NSG, and allowed callers.
3. Size master, data, and dashboard nodes.
4. Decide snapshot/export bucket requirements.
5. Apply the cluster after cost and security review.
6. Hand endpoint outputs to ingestion and application blueprints.

## Traffic And Trust Boundaries

- OpenSearch should normally live in private subnets.
- NSGs should separate app callers, ingestion jobs, and admin access.
- Dashboard access should be more restricted than application search access.
- Snapshot buckets may contain sensitive indexed data.
- Vector indexes can expose source-document semantics and should be protected.

## Detailed Architecture Notes

The cluster resource exposes a large number of sizing inputs because OpenSearch
cost and performance are sensitive to node count, memory, OCPU, and storage.
The defaults are intentionally small for example purposes, not production
guidance.

The blueprint does not create indexes. Index templates, analyzers, vector
mappings, and lifecycle policies usually belong to the application or ingestion
pipeline because they change more often than the landing-zone foundation.

Snapshot bucket creation is optional so customers can use centralized backup or
data-platform storage when that already exists.

## Operational Boundaries

- Do not commit admin password hashes, customer index mappings, or source data.
- Keep subnet, NSG, and security settings in local tfvars.
- Use this before `embedding-pipeline` or `multi-agent` when vectors are needed.
- Pair with backup and monitoring runbooks for production clusters.

## Review Checklist

- [ ] VCN, subnet, and NSG are correct.
- [ ] Node sizing is approved for workload and budget.
- [ ] Security mode and admin access are reviewed.
- [ ] Snapshot strategy is documented.
- [ ] Index writers and readers are least privilege.
- [ ] Outputs are handed to only approved consumers.
