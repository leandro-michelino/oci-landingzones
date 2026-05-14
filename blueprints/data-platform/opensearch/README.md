# OpenSearch Search And Vector Platform

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this blueprint when the customer needs OCI Search with OpenSearch for
application search, log-style indexing, semantic search, or vector/RAG
workloads.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/data-platform/opensearch` |
| Best fit | Managed OpenSearch cluster for search and vector index workloads. |
| Terraform shape | OpenSearch cluster, snapshot bucket, IAM policy. |
| Default posture | Cluster creation is disabled until subnet, sizing, security, and cost are reviewed. |

## What This Deploys

| Resource | Enable Flag |
| --- | --- |
| OpenSearch cluster | `create_cluster` |
| Snapshot/export bucket | `create_snapshot_bucket` |
| IAM policy shell | `policy_statements` not empty |

## Inputs To Decide

| Input | What To Decide |
| --- | --- |
| `vcn_id`, `subnet_id`, `nsg_id` | Private network placement. |
| `master_node_*`, `data_node_*`, `opendashboard_*` | Cluster shape and cost profile. |
| `security_*` | OpenSearch security mode and admin identity. |
| `policy_statements` | Admin, writer, and read-only consumer access. |

## Deployment Order

Deploy Core and Networking first. Use this before `embedding-pipeline`,
`multi-agent`, or other AI patterns that need a vector/search target.

## Outputs

| Output | Meaning |
| --- | --- |
| `opensearch_cluster_id` | OpenSearch cluster OCID. |
| `opensearch_endpoint` | Search endpoint FQDN. |
| `opendashboard_endpoint` | Dashboard endpoint FQDN. |
| `snapshot_bucket_name` | Snapshot/export bucket name. |
| `access_policy_id` | IAM policy OCID. |

## Validation

```bash
terraform fmt -check
terraform init -backend=false
terraform validate
ansible-playbook ansible/plan.yml
```
