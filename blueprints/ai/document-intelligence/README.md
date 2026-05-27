# Document Intelligence Pipeline

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this blueprint for document intake workflows that combine Object Storage,
OCI Document Understanding, Oracle Functions orchestration, and optional GenAI
reasoning or summarization.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/ai/document-intelligence` |
| Best fit | Intake, extraction, reasoning, and structured output for PDFs, images, contracts, invoices, claims, and reports. |
| Terraform shape | Intake/output/failed buckets, Document Understanding project, Events trigger, IAM policy. |
| Default posture | Buckets, projects, and event triggers are disabled until reviewed. |

## Practical Use Cases

- **Invoice and claims extraction:** Turn PDFs or images into structured records that downstream systems can validate.
- **Contract review intake:** Extract clauses, parties, dates, obligations, and risk markers before human review.
- **Report summarization:** Process long reports into searchable, structured, or summarized outputs.
- **Back-office automation:** Reduce manual document handling while keeping storage and processing boundaries visible.

## What This Deploys

| Resource | Enable Flag |
| --- | --- |
| Intake/output/failed buckets | `create_buckets` |
| Document Understanding project | `create_document_project` |
| Events rule to handler Function | `create_event_rule` |
| IAM policy shell | `policy_statements` not empty |

## Inputs To Decide

| Input | What To Decide |
| --- | --- |
| `handler_function_id` | Function that orchestrates extract, GenAI call, and output write. |
| `event_rule_condition` | Object Storage event condition for intake objects. |
| `*_bucket_name` | Customer-approved bucket names and data retention. |
| `policy_statements` | Bucket, Document Understanding, Functions, and GenAI access. |

## Deployment Order

Deploy this after Core and the target private networking path. Use Functions
and `genai-private` when the customer wants private orchestration and private
GenAI access.

## Outputs

| Output | Meaning |
| --- | --- |
| `bucket_names` | Intake, output, and failed bucket names. |
| `document_project_id` | Document Understanding project OCID. |
| `events_rule_id` | Events trigger OCID. |
| `access_policy_id` | IAM policy OCID. |

## What Good Looks Like

- Document intake locations, output schema, and retention expectations are defined.
- Extraction results are validated against representative sample documents.
- Human review points are clear for low-confidence or high-risk outputs.
- The pipeline records enough metadata to troubleshoot bad extractions.

## Validation

```bash
terraform fmt -check
terraform init -backend=false
terraform validate
ansible-playbook ansible/plan.yml
```
