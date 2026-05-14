# OCI AI Services Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

## Deployment Purpose

Create a landing-zone-ready shape for pretrained OCI AI Services. The blueprint
sets up service projects, private data buckets, optional Vision private access,
and IAM so applications can call Vision, Language, and Document Understanding
without adopting a full GenAI platform.

## Architecture At A Glance

| Layer | Responsibility |
| --- | --- |
| Input bucket | Stores images, documents, audio metadata, or text payloads. |
| AI service projects | Group Document, Language, and Vision work. |
| Vision private endpoint | Optional private network path for Vision. |
| Output bucket | Stores inference results and extracted metadata. |
| IAM | Controls service callers and data readers. |

## ASCII Architecture

```text
Application / Integration
      |
      v
Input Bucket
      |
      | service API calls
      v
OCI AI Services
 |-- Document Understanding project
 |-- Language project
 |-- Vision project
 |-- Vision private endpoint
      |
      v
Output Bucket
      |
      v
Application / ODA / OIC / Analytics

IAM controls callers, service accounts, and bucket access.
```

## Terraform Components

| File | Purpose |
| --- | --- |
| `main.tf` | Buckets, AI service projects, Vision private endpoint, IAM policy. |
| `variables.tf` | Project, bucket, endpoint, and policy inputs. |
| `outputs.tf` | Project IDs, endpoint ID, bucket names, and policy hand-off. |
| `terraform.tfvars.example` | Service-selection example with create flags disabled. |
| `ansible/*.yml` | Standard local runners. |

## Request And Deployment Flow

1. Choose the pretrained service capabilities needed.
2. Confirm input/output bucket retention and encryption.
3. Decide whether Vision needs private endpoint access.
4. Configure IAM for callers and service accounts.
5. Run plan and apply.
6. Hand project and bucket outputs to application owners.

## Traffic And Trust Boundaries

- Input and output data can contain sensitive documents, text, and images.
- Private endpoint use depends on service support and customer network policy.
- Application callers should not automatically receive output bucket read access.
- Service projects should sit in the workload or AI platform compartment.
- Data retention should match the customer classification of processed content.

## Detailed Architecture Notes

This blueprint is intentionally separate from `genai-private`. Many customers
need OCR, classification, sentiment, entity extraction, or image analysis before
they need LLM endpoints. Keeping pretrained AI services separate makes adoption
lighter and IAM easier to explain.

The project resources give teams a consistent control plane anchor. Buckets are
optional because some customers already operate centralized data landing zones.

Vision private endpoint support is exposed because image workloads frequently
touch confidential or regulated data.

## Operational Boundaries

- Do not commit source documents, images, transcripts, or inference outputs.
- Keep bucket names, subnet IDs, and caller groups in local tfvars.
- Use `document-intelligence` for event-driven document pipelines.
- Use `genai-guardrails` when outputs are fed into GenAI prompts.

## Review Checklist

- [ ] Selected AI services match the workload.
- [ ] Bucket retention and encryption are approved.
- [ ] Vision private endpoint subnet is correct when enabled.
- [ ] Caller and service-account IAM statements are least privilege.
- [ ] Output consumers are documented.
- [ ] Sensitive data handling is approved.
