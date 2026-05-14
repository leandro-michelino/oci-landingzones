# Multi-Agent Orchestration

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this blueprint when a customer needs an orchestrator agent, specialist
agents, shared task hand-off, tool registry storage, audit logs, and IAM
boundaries for agentic workflows.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/ai/multi-agent` |
| Best fit | Orchestrator plus specialist agents for search, data, code, or workflow automation. |
| Terraform shape | Buckets, Streaming, GenAI Agent knowledge base, agents, endpoint, tools, IAM policy. |
| Default posture | All service resources are disabled until model, tool, and ownership decisions are reviewed. |

## What This Deploys

| Resource | Enable Flag |
| --- | --- |
| Audit/tool buckets | `create_buckets` |
| Task stream pool | `create_stream_pool` |
| Inter-agent task stream | `create_task_stream` |
| Knowledge base | `create_knowledge_base` |
| Orchestrator agent | `create_orchestrator_agent` |
| Orchestrator endpoint | `create_orchestrator_endpoint` |
| Specialist agents | `specialist_agents` map |
| Agent tools | `agent_tools` map |

## Inputs To Decide

| Input | What To Decide |
| --- | --- |
| `orchestrator_model_id` | Model used by the orchestrator. |
| `specialist_agents` | Which specialist agents exist and what knowledge they can use. |
| `agent_tools` | Tool definitions and permission boundaries. |
| `opensearch_cluster_id` | Optional knowledge base index target. |
| `policy_statements` | Per-agent and operator IAM boundaries. |

## Deployment Order

Deploy Core, Networking, `genai-private`, optional `opensearch`, and
`embedding-pipeline` first when a full RAG-backed agent platform is needed.
Then enable this blueprint in stages: storage, stream, knowledge base, agents,
endpoint, tools.

## Outputs

| Output | Meaning |
| --- | --- |
| `orchestrator_agent_id` | Top-level agent OCID. |
| `orchestrator_endpoint_id` | Agent endpoint OCID. |
| `specialist_agent_ids` | Specialist agent OCIDs. |
| `streaming_topic_id` | Inter-agent task stream OCID. |
| `tool_ids` | Tool OCIDs keyed by logical name. |

## Validation

```bash
terraform fmt -check
terraform init -backend=false
terraform validate
ansible-playbook ansible/plan.yml
```
