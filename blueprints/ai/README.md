# AI Blueprints

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This family contains deployable landing-zone patterns for AI and GenAI services.
Each child folder follows the standard repo contract: Terraform files, local
Ansible runners, operator README, and ASCII architecture notes.

## Deployments

| Deployment | Use It When |
|---|---|
| [AI Agents RAG Landing Zone](agents/) | You need a GenAI Agent, knowledge base, Object Storage data source, ingestion job, and private endpoint hand-off. |
| [OCI AI Services](ai-services/) | You need pretrained Vision, Language, and Document Understanding project wiring. |
| [Document Intelligence Pipeline](document-intelligence/) | You need Object Storage intake, Document Understanding, Functions orchestration, and structured outputs. |
| [Embedding And Vector Ingestion Pipeline](embedding-pipeline/) | You need documents chunked, embedded with GenAI, and sent to OpenSearch or another vector target. |
| [GenAI Fine-Tuning And Dedicated AI Cluster](genai-fine-tuning/) | You need training data, dedicated AI cluster, fine-tuned model, and optional endpoint hand-off. |
| [GenAI Guardrails And Observability](genai-guardrails/) | You need prompt audit, alarms, Cloud Guard hooks, and security reviewer hand-offs. |
| [GenAI Multi-Model Gateway](genai-gateway/) | You need API Gateway routing, quotas, usage plans, and audit controls in front of GenAI endpoints. |
| [OCI Generative AI Private Landing Zone](genai-private/) | You need private OCI Generative AI access with archive and IAM controls. |
| [Multi-Agent Orchestration](multi-agent/) | You need orchestrator and specialist agents, Streaming task hand-off, tools, and session audit. |
