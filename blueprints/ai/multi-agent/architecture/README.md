# Multi-Agent Orchestration Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

## Deployment Purpose

Provide a controlled platform shape for agentic systems. The blueprint wires an
orchestrator agent, specialist agents, knowledge base, task stream, tool
registry buckets, session audit storage, and IAM so teams can build multi-agent
workflows without inventing the foundation each time.

## Architecture At A Glance

| Layer | Responsibility |
| --- | --- |
| Orchestrator agent | Plans and routes work to specialist agents or tools. |
| Specialist agents | Handle focused tasks such as search, data, workflow, or code. |
| Knowledge base | Shared RAG context backed by OpenSearch or database connection. |
| Task stream | Durable task dispatch and hand-off between agents. |
| Tool registry | Stores approved tool definitions and schema metadata. |
| Audit bucket | Stores session traces and execution evidence. |
| IAM | Enforces per-agent and per-tool permission boundaries. |

## ASCII Architecture

```text
User / App Caller
      |
      v
Orchestrator Agent Endpoint
      |
      v
Orchestrator Agent
 |-- routing model
 |-- knowledge base
 |-- tool registry
 |
 |-- Streaming task stream ------------------+
 |                                           |
 |-- Search Specialist Agent                 |
 |-- Data Specialist Agent                   |
 |-- Workflow Specialist Agent               |
 `-- Custom Specialist Agent                 |
      |                                      |
      | tools + bounded IAM                  |
      v                                      v
Functions / APIs / OpenSearch / Databases / SaaS
      |
      v
Session Audit Bucket + Security Review
```

## Terraform Components

| File | Purpose |
| --- | --- |
| `main.tf` | Buckets, stream, GenAI Agent resources, endpoint, tools, and IAM policy. |
| `variables.tf` | Agent, model, knowledge base, stream, tool, and policy inputs. |
| `outputs.tf` | Agent, endpoint, stream, tool, bucket, and policy hand-offs. |
| `terraform.tfvars.example` | Disabled-by-default sample agent configuration. |
| `ansible/*.yml` | Standard local runners. |

## Request And Deployment Flow

1. Confirm the business tasks and specialist-agent boundaries.
2. Confirm which knowledge bases and tools each agent can access.
3. Deploy or reference OpenSearch and embedding pipelines if RAG is required.
4. Create the task stream and audit/tool buckets.
5. Create orchestrator and specialist agents.
6. Enable endpoint and tools only after policy review.

## Traffic And Trust Boundaries

- Each agent should have the smallest useful tool and data access.
- Tool calls should be auditable and tied to a session.
- Session traces may include sensitive user intent and retrieved data.
- Streaming topics should not be readable by unrelated workloads.
- Cross-agent trust must be explicit; do not grant broad compartment access.

## Detailed Architecture Notes

Multi-agent systems fail quietly when all tools share the same broad identity.
This blueprint keeps agent, tool, stream, and audit boundaries visible so the
security review can reason about which component can do what.

The orchestrator can attach to a created knowledge base or to existing knowledge
bases. Specialist agents are modeled as a map so a customer can start with one
specialist and add more without changing the folder shape.

Tools are optional because many early customers first validate agent routing and
RAG before allowing external actions.

## Operational Boundaries

- Do not commit prompts, session traces, tool credentials, or customer schemas.
- Keep model IDs, knowledge base IDs, and tool definitions in local tfvars or an
  approved pipeline variable store.
- Pair with `genai-guardrails` for prompt/session audit.
- Pair with `embedding-pipeline` and `opensearch` for RAG-backed specialists.

## Review Checklist

- [ ] Orchestrator and specialist roles are documented.
- [ ] Model and endpoint IDs are approved.
- [ ] Tool definitions are reviewed before enabling.
- [ ] Agent IAM boundaries are least privilege.
- [ ] Session audit destination and retention are approved.
- [ ] Streaming task retention and reader permissions are clear.
