# AI Agents RAG Landing Zone Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

## Deployment Purpose

This blueprint creates the deployable landing-zone shape for an OCI GenAI Agent
RAG workload. It gives teams a documented path from approved source documents
to a knowledge base, indexed retrieval, agent endpoint access, and audit handoff.
All expensive or externally visible resources are disabled by default.

## Architecture At A Glance

| Layer | Components |
| --- | --- |
| Intake | Object Storage source bucket and optional existing prefixes. |
| Processing | Data source and ingestion job attached to a GenAI Agent knowledge base. |
| Retrieval | OpenSearch or compatible knowledge base index configuration. |
| Reasoning | OCI GenAI Agent and optional endpoint with sessions, traces, and citations. |
| Governance | IAM policy shell, audit bucket, tags, and operator review gates. |

## ASCII Architecture

```text
+--------------------------------------------------------------------------------+
|                         AI Agents RAG Landing Zone                              |
+--------------------------------------------------------------------------------+
|                                                                                |
|  Data Steward                                                                  |
|      |                                                                         |
|      v                                                                         |
|  Source Documents                                                              |
|  Object Storage bucket or approved existing prefixes                           |
|      |                                                                         |
|      v                                                                         |
|  GenAI Agent Data Source                                                       |
|      |                                                                         |
|      v                                                                         |
|  Data Ingestion Job                                                            |
|      |                                                                         |
|      v                                                                         |
|  Knowledge Base                                                                |
|      |                                                                         |
|      +--> OpenSearch / vector index backend                                    |
|      |       |                                                                 |
|      |       `--> chunk, embedding, title, URL, and body schema                 |
|      |                                                                         |
|      v                                                                         |
|  OCI GenAI Agent                                                               |
|      |                                                                         |
|      +--> model or endpoint selection                                          |
|      +--> answer instruction                                                   |
|      +--> citations and trace options                                          |
|      |                                                                         |
|      v                                                                         |
|  Agent Endpoint                                                                |
|      |                                                                         |
|      `--> App, API Gateway, ODA, OIC, or internal caller                       |
|                                                                                |
|  Governance Lane                                                               |
|      |                                                                         |
|      +--> IAM policy statements for caller and ingestion groups                |
|      +--> Audit bucket for session and document lineage hand-off               |
|      `--> Tags for ownership, environment, and cost attribution                |
+--------------------------------------------------------------------------------+
```

## Terraform Components

| File | Purpose |
| --- | --- |
| `main.tf` | Creates buckets, GenAI Agent knowledge base, data source, ingestion job, agent, endpoint, and optional IAM policy. |
| `variables.tf` | Defines the create/reference contract for buckets, indexes, model selection, data sources, and policies. |
| `outputs.tf` | Exposes bucket names, knowledge base, data source, agent, endpoint, and policy identifiers. |
| `terraform.tfvars.example` | Shows safe placeholder values for extension-only and full deployment paths. |

## Request And Deployment Flow

1. Data owners approve document locations and prefixes.
2. Platform owners deploy or reference the OpenSearch/vector backend.
3. Terraform creates or references the knowledge base and data source.
4. An optional ingestion job indexes the approved source documents.
5. Terraform creates or references the agent and endpoint.
6. Applications call the endpoint through the customer-approved access path.
7. Operators review audit and trace outputs outside the local IaC artifact path.

## Traffic And Trust Boundaries

- Source content is explicitly scoped through Object Storage prefixes.
- Agent endpoint access should stay private unless a separate edge blueprint is
  used and approved.
- IAM policies should separate data stewards, ingestion operators, app callers,
  and audit readers.
- The knowledge base backend is treated as a data system, not just an AI helper.
- Full prompt/session logging can contain sensitive content and must follow the
  same retention model as the source documents.

## Detailed Architecture Notes

- `create_buckets` creates a clean document/audit bucket set for greenfield use.
- `data_source_prefixes` supports extension-only deployments where documents
  already live in customer-managed buckets.
- `knowledge_base_indexes` lets the customer align body, embedding, title, and
  URL field names with an existing OpenSearch schema.
- `create_ingestion_job` is intentionally separate from data-source creation so
  operators can plan the metadata path before indexing content.
- Model selection supports either a base model OCID or a dedicated endpoint OCID.
- Citation, session, and trace switches are endpoint-level because customers
  often choose different defaults for production and support environments.

## Operational Boundaries

- Terraform does not upload source documents or curate the corpus.
- Terraform does not tune chunking, embeddings, or ranking logic by itself.
- Ingestion jobs should be reviewed before re-running against large buckets.
- Sensitive data review belongs before `create_data_source` is enabled.
- Cost and token controls should be combined with GenAI gateway or guardrails
  blueprints for shared platform deployments.

## Review Checklist

- Source bucket prefixes are approved by the data owner.
- Knowledge base backend and index schema are reviewed.
- Model or endpoint OCIDs are available in the target region.
- Agent endpoint exposure is private or explicitly approved.
- IAM statements are least-privilege and group-based.
- Audit and trace retention are documented.
- Terraform plan shows no unexpected public access or unmanaged document paths.
