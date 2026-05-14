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

## Validation

```bash
terraform fmt -check
terraform init -backend=false
terraform validate
ansible-playbook ansible/plan.yml
```
