# Embedding And Vector Ingestion Pipeline Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

## Deployment Purpose

Create a reusable ingestion foundation for semantic search and RAG workloads.
The blueprint wires source storage, pipeline state, optional Streaming hand-off,
an Events trigger, and IAM around external chunking and embedding functions.

## Architecture At A Glance

| Layer | Responsibility |
| --- | --- |
| Source bucket | Holds documents or records to embed. |
| Events rule | Starts chunking when new objects arrive. |
| Chunking Function | Splits source files into model-sized chunks. |
| Embedding Function | Calls OCI GenAI embedding model. |
| Streams | Decouple chunk and vector stages when needed. |
| Vector target | OpenSearch or another vector database/index. |
| State bucket | Tracks processed versions and checkpoints. |

## ASCII Architecture

```text
Source Documents
      |
      v
Object Storage Source Bucket
      |
      | createobject event
      v
OCI Events Rule
      |
      v
Chunking Function
      |
      | chunks
      v
Streaming: chunks topic
      |
      v
Embedding Function
      |
      | OCI GenAI embedding model
      v
Streaming: vectors topic
      |
      v
OpenSearch Vector Index
      |
      v
RAG App / Search API / Agent Knowledge Base

State Bucket tracks processed object versions.
Failed Bucket stores retry evidence.
```

## Terraform Components

| File | Purpose |
| --- | --- |
| `main.tf` | Buckets, stream pool, streams, Events rule, and IAM policy. |
| `variables.tf` | Function, embedding model, vector target, bucket, stream, and policy inputs. |
| `outputs.tf` | Buckets, streams, event rule, model, index, and policy outputs. |
| `terraform.tfvars.example` | Disabled-by-default sample values. |
| `ansible/*.yml` | Standard local runners. |

## Request And Deployment Flow

1. Confirm source content types and chunking strategy.
2. Deploy or identify the vector index target.
3. Deploy chunking and embedding Functions.
4. Enable buckets and streams.
5. Enable the Events rule only after handlers are ready.
6. Hand vector index and stream outputs to RAG applications.

## Traffic And Trust Boundaries

- Source documents may contain sensitive data.
- Embedding vectors may still reveal information and should be protected.
- Functions need least-privilege access to buckets, streams, GenAI, and target index.
- Private endpoints are preferred for regulated workloads.
- Failed bucket access should be limited to operators and data owners.

## Detailed Architecture Notes

The blueprint deliberately keeps business logic out of Terraform. Chunking,
embedding, filtering, and schema mapping belong in Functions or application
code. Terraform owns the durable platform pieces and output contracts.

Streaming is optional. Small customers can run object event to function directly.
Larger pipelines can use streams to decouple chunking, embedding, and indexing
so retries and back-pressure are easier to operate.

The state bucket enables incremental re-indexing by storing object versions,
checksums, or batch checkpoints.

## Operational Boundaries

- Do not commit source documents, generated vectors, or customer index schemas.
- Keep model IDs, endpoint URLs, and function IDs in local tfvars.
- Pair with `opensearch` for the managed search/vector target.
- Pair with `genai-guardrails` when prompt or embedding calls require audit.

## Review Checklist

- [ ] Chunk size and overlap strategy are documented.
- [ ] Embedding model ID is approved and region-supported.
- [ ] Vector index endpoint and index name are correct.
- [ ] Events rule is disabled until handlers are deployed.
- [ ] IAM covers only required bucket, stream, GenAI, and index access.
- [ ] Retry and failed-object handling are owned.
