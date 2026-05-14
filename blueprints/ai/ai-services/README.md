# OCI AI Services

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this blueprint for OCI AI Services projects: Vision, Language, Document
Understanding, and supporting input/output buckets. It is separate from GenAI so
customers can use pretrained service APIs without a model-serving platform.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/ai/ai-services` |
| Best fit | Pretrained Vision, Language, and Document Understanding service setup. |
| Terraform shape | Input/output buckets, service projects, optional Vision private endpoint, IAM policy. |
| Default posture | Projects and buckets are disabled until the required services are chosen. |

## What This Deploys

| Resource | Enable Flag |
| --- | --- |
| Input/output buckets | `create_buckets` |
| Document project | `enable_document_project` |
| Language project | `enable_language_project` |
| Vision project | `enable_vision_project` |
| Vision private endpoint | `create_vision_private_endpoint` |
| IAM policy shell | `policy_statements` not empty |

## Inputs To Decide

| Input | What To Decide |
| --- | --- |
| `enable_*_project` | Which pretrained AI services the customer needs. |
| `vision_private_endpoint_subnet_id` | Private subnet for Vision workloads when required. |
| `input_bucket_name`, `output_bucket_name` | Data hand-off bucket names. |
| `policy_statements` | Caller, service-account, and bucket permissions. |

## Deployment Order

Use this after Core and the required networking foundation. It can feed
Document Intelligence, ODA/OIC integrations, or custom applications that call
OCI pretrained AI APIs.

## Outputs

| Output | Meaning |
| --- | --- |
| `document_project_id` | Document project OCID. |
| `language_project_id` | Language project OCID. |
| `vision_project_id` | Vision project OCID. |
| `vision_private_endpoint_id` | Vision private endpoint OCID. |
| `bucket_names` | Input/output bucket names. |

## Validation

```bash
terraform fmt -check
terraform init -backend=false
terraform validate
ansible-playbook ansible/plan.yml
```
