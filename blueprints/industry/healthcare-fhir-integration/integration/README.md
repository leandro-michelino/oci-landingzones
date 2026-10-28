# Hospital Integration Handoffs

This is an implementation contract for external components, not delivered
middleware. Agree owners and test the following before enabling real traffic.

| Boundary | Required external work | Acceptance evidence |
| --- | --- | --- |
| EHR/HIS/LIS/PACS to FHIR | Select source interfaces, mapping engine and target implementation guides; define identifier, terminology and version rules. | Approved mappings and synthetic-message tests; not inferred from a resource name. |
| HL7 v2 adapters | Configure transport, ACK/NACK, duplicate detection, retry, reconciliation and failure ownership. No MLLP port/listener is opened here. | Adapter tests with non-patient fixtures and agreed recovery behavior. |
| Identity to API | Provide trusted issuer/audience values and a reachable HTTPS JWKS endpoint. | Missing/invalid token denied; expired/wrong-issuer/wrong-audience tokens denied; rotation tested. |
| API to FHIR | Configure private DNS/routes, TLS trust, identity context and backend patient/resource authorization. | Correct authorized reads; unauthorized patient/search access denied; direct-backend bypass tested. |
| Integration worker to Queue | Deploy a producer/consumer in the supplied subnet/NSG, with explicit IAM/KMS permissions and reviewed event schema. | Delivery, retries, duplicate handling and native dead-letter/replay procedures tested. |
| Clinical audit and operations | Implement application audit, consent handling, redaction and operator access controls. | Required audit events recorded without dumping full records or tokens into infrastructure logs. |

FHIR acceptance should start with the backend's actual
[CapabilityStatement](https://hl7.org/fhir/R4/capabilitystatement.html), then compare
its supported profiles/resources/interactions with the gateway route subset.
Use synthetic fixtures. Verify query parameters, paging links, `_format`, HTTP
status/OperationOutcome, conditional requests and headers through the proxy;
none of those runtime behaviors were established by Terraform tests.

The route template provides metadata plus configured collection/instance paths.
It does not explicitly model system transaction/batch, bulk export, subscriptions,
history, custom operations or cross-version translation. A backend operation that
happens to match a dynamic route still needs backend authorization and validation.
DELETE is absent from the configured method allowlist.

For two-project use, deploy compatible clinical software separately in the
patient-data project, approve its storage/database choice, and add deliberate
connectivity and identity rules. Do not equate an ADB instance or a private HTTPS
VM with a FHIR server. No interoperability, clinical correctness, data residency,
restore or regulatory outcome is certified by these infrastructure blueprints.
