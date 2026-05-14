# AI Agents RAG Landing Zone

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this blueprint when a team needs a private retrieval augmented generation
stack with OCI GenAI Agent, a knowledge base, Object Storage document intake,
OpenSearch or compatible indexing, ingestion jobs, and session/audit hand-offs.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/ai/agents` |
| Best fit | Agentic RAG over approved enterprise documents. |
| Terraform shape | Object Storage buckets, GenAI Agent knowledge base, data source, ingestion job, agent endpoint, IAM policy. |
| Default posture | Creation flags are disabled until customer OCIDs and index design are reviewed. |
| Customer paths | Extension-only with existing buckets/OpenSearch/agent, or base-plus-extension after Core, Networking, OpenSearch, and GenAI. |

## What This Deploys

| Resource | Enable Flag |
| --- | --- |
| Source, processed, and audit buckets | `create_buckets` |
| GenAI Agent knowledge base | `create_knowledge_base` |
| Object Storage data source | `create_data_source` |
| Data ingestion job | `create_ingestion_job` |
| GenAI Agent and endpoint | `create_agent`, `create_agent_endpoint` |
| IAM policy shell | `policy_statements` not empty |

## Inputs To Decide

Start with `terraform.tfvars.example`, then create a local ignored
`terraform.tfvars` with real OCIDs, model choices, and document prefixes.

| Input | What To Decide |
| --- | --- |
| `opensearch_cluster_id` | Vector/search backend for the knowledge base. |
| `data_source_prefixes` | Approved Object Storage locations for indexed content. |
| `agent_model_id` or `agent_endpoint_model_id` | Model used for response generation. |
| `create_ingestion_job` | Whether Terraform should trigger the first ingestion run. |
| `policy_statements` | Caller, ingestion operator, and data steward permissions. |

## Deployment Order

This blueprint supports both extension-only and base-plus-extension paths.
For extension-only use, provide existing knowledge base, agent, bucket, or
OpenSearch values. For base-plus-extension use, deploy Core, Networking,
OpenSearch, and a GenAI foundation first, then pass their outputs here.

1. Confirm source document ownership and retention rules.
2. Confirm the vector/search backend and index schema.
3. Review the model, prompt instructions, citation behavior, and audit scope.
4. Run `terraform plan` or `ansible-playbook ansible/plan.yml`.
5. Apply only after data-source prefixes and IAM caller groups are approved.

## Outputs

| Output | Meaning |
| --- | --- |
| `knowledge_base_id` | GenAI Agent knowledge base OCID. |
| `data_source_id` | GenAI Agent data source OCID. |
| `agent_id` | RAG agent OCID. |
| `agent_endpoint_id` | Agent endpoint OCID. |
| `bucket_names` | Source, processed, and audit bucket names. |

## Validation

Run from this folder:

```bash
terraform fmt -check
terraform init -backend=false
terraform validate
```

For repo-standard execution:

```bash
ansible-playbook ansible/plan.yml
```

See `architecture/README.md` before using this in a customer review.
