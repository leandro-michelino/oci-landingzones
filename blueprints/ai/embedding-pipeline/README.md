# Embedding And Vector Ingestion Pipeline

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this blueprint when documents or records need to be chunked, embedded with
OCI GenAI, and indexed into OpenSearch or another vector search target.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/ai/embedding-pipeline` |
| Best fit | Standalone embedding ingestion for RAG, semantic search, and knowledge-base refresh. |
| Terraform shape | Source/state/failed buckets, optional streams, Events trigger, IAM policy. |
| Default posture | Storage, streams, and events are disabled until the pipeline handlers exist. |

## What This Deploys

| Resource | Enable Flag |
| --- | --- |
| Source/state/failed buckets | `create_buckets` |
| Stream pool | `create_stream_pool` |
| Chunk/vector streams | `create_streams` |
| Object-created event rule | `create_event_rule` |
| IAM policy shell | `policy_statements` not empty |

## Inputs To Decide

| Input | What To Decide |
| --- | --- |
| `chunking_function_id` | Function that splits source content into chunks. |
| `embedding_model_id` | OCI GenAI embedding model OCID. |
| `opensearch_endpoint` | Vector target endpoint from the OpenSearch blueprint or external service. |
| `vector_index_name` | Target vector index. |
| `streams` | Chunk and vector event partitioning and retention. |

## Deployment Order

Deploy OpenSearch or another vector target first, then deploy Functions handlers,
then enable the Events trigger. For full landing zones, Core, Networking,
`genai-private`, `opensearch`, and Functions normally come before this folder.

## Outputs

| Output | Meaning |
| --- | --- |
| `bucket_names` | Source, state, and failed bucket names. |
| `stream_pool_id` | Stream pool OCID. |
| `stream_ids` | Stream OCIDs keyed by logical name. |
| `events_rule_id` | Source object trigger rule OCID. |
| `vector_index_name` | Target index name. |

## Validation

```bash
terraform fmt -check
terraform init -backend=false
terraform validate
ansible-playbook ansible/plan.yml
```
