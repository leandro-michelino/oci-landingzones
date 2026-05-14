# Document Intelligence Pipeline Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

## Deployment Purpose

Provide a reusable document-processing landing zone that starts with Object
Storage intake, extracts content with OCI Document Understanding, optionally
reasons over it with GenAI, and writes structured outputs for downstream
systems.

## Architecture At A Glance

| Layer | Responsibility |
| --- | --- |
| Intake bucket | Drop zone for PDFs, images, contracts, claims, and reports. |
| Events rule | Starts processing when new documents arrive. |
| Handler Function | Orchestrates extraction, GenAI call, error handling, and output writes. |
| Document project | Groups Document Understanding processors and jobs. |
| Output bucket | Stores structured JSON, extracted text, and summaries. |
| Failed bucket | Keeps rejected or failed documents for retry and evidence. |

## ASCII Architecture

```text
Business App / User Upload
        |
        v
Object Storage Intake Bucket
        |
        | createobject event
        v
OCI Events Rule
        |
        v
Oracle Functions Handler
 |-- Document Understanding project
 |-- OCI GenAI endpoint or gateway
 |-- validation and retry logic
 |
 |-- success --> Output Bucket (JSON/text/summary)
 `-- failure --> Failed Bucket (evidence/retry)
        |
        v
Downstream App / Data Catalog / Analytics
```

## Terraform Components

| File | Purpose |
| --- | --- |
| `main.tf` | Buckets, Document Understanding project, Events rule, and IAM policy. |
| `variables.tf` | Bucket, function, event, project, and policy inputs. |
| `outputs.tf` | Buckets, project, event rule, and policy hand-offs. |
| `terraform.tfvars.example` | Disabled-by-default example values. |
| `ansible/*.yml` | Standard local runners. |

## Request And Deployment Flow

1. Confirm document types and target output schema.
2. Confirm retention and encryption for intake, output, and failed buckets.
3. Deploy or reference the handler Function.
4. Create the Document Understanding project.
5. Enable Events rule after the handler is ready.
6. Hand output bucket and schema details to downstream consumers.

## Traffic And Trust Boundaries

- Intake documents may contain regulated or confidential data.
- Failed documents should be treated as sensitive evidence, not casual logs.
- Functions should use private subnets where customer policy requires it.
- GenAI calls should route through private endpoints or `genai-gateway` when
  the workload requires controlled egress and audit.
- Bucket writers, processors, and readers should be separate IAM subjects.

## Detailed Architecture Notes

This blueprint does not prescribe one processor type because invoices, receipts,
contracts, claims, and general PDFs have different extraction needs. It creates
the common landing-zone wiring and leaves processor/job specifics to the
handler implementation.

The failed bucket is part of the architecture on purpose. Production document
pipelines need retry evidence, malformed-file review, and a place to preserve
inputs that could not be processed.

The handler Function is supplied as an OCID so teams can pair this blueprint
with the existing Oracle Functions extension or with an externally managed
function app.

## Operational Boundaries

- Do not commit sample customer documents or extracted text.
- Keep event conditions, function IDs, bucket names, and schema notes in local
  tfvars or controlled pipeline variables.
- Use `genai-guardrails` when prompts or extracted text are archived.
- Use `ai-services` when the customer needs broader Vision or Language projects.

## Review Checklist

- [ ] Document classes and output schema are approved.
- [ ] Intake, output, and failed bucket retention is approved.
- [ ] Handler Function exists before enabling the Events rule.
- [ ] IAM allows only required bucket, Document, Function, and GenAI actions.
- [ ] Failed-document operations and retry runbook are clear.
- [ ] Downstream consumers understand output location and format.
