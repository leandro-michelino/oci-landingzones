# Hospital Integration And FHIR Landing Zone

Private OCI integration infrastructure in front of an existing hospital FHIR R4
service. This blueprint separates API authentication/routing and asynchronous
integration-event infrastructure from clinical server software and patient data.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/industry/healthcare-fhir-integration` |
| Best fit | Private hospital FHIR API mediation with explicit identity, backend and integration-worker handoffs. |
| Terraform shape | Private VCN, API/integration subnets, NSGs, service gateway, existing-DRG attachment, flow logs, authenticated API Gateway/deployment and optional encrypted Queue. |
| Default posture | All cloud creation disabled; GET-only routes if API is enabled after prerequisites. |
| Existing prerequisites | Private FHIR R4 server, backend patient/resource authorization, identity issuer/JWKS, DRG transport/routes/DNS and optional queue KMS key/permissions. |
| Companion project | [Patient application/data foundation](../healthcare-platform/README.md); no automatic connection or data sharing. |

## What Is Created

`enable_foundation=true` with `costs_approved=true` creates a private network with
API and integration subnets, empty attached security list, explicit NSGs, regional
OSN access and two flow-log configurations. No Internet Gateway, NAT or public
API endpoint is created. `drg_id` enables a VCN attachment and routes to the
supplied client, FHIR backend and JWKS prefixes; remote routing remains external.

`enable_api=true` creates a PRIVATE API Gateway and deployment under `/fhir`.
TOKEN_AUTHENTICATION validates Bearer tokens using remote JWKS over verified TLS,
with trusted issuer and audience inputs and anonymous access disabled.
Oracle documents this policy in its
[token authentication guide](https://docs.oracle.com/en-us/iaas/Content/APIGateway/Tasks/apigatewayusingjwttokens-usinjson.htm).
The operator must supply private network reachability for the backend and JWKS;
the JWKS endpoint must be readable without its own authentication.
Supply existing `ca_bundle_ids` when hospital backend/JWKS TLS uses private PKI;
no CA or bundle is created. Outbound trust must be tested.

Default allowlisted resources are Patient, Encounter, Observation,
DiagnosticReport and DocumentReference. The proxy exposes `/metadata`, resource
collections and `/{id}` reads. Optional POST is limited to collections;
PUT/PATCH are limited to instance routes. DELETE is not exposed. Route URLs bind
the request ID to the backend path using Oracle's
[HTTP backend context variables](https://docs.oracle.com/en-us/iaas/Content/APIGateway/Tasks/apigatewayusinghttpbackend.htm).

The route subset follows [FHIR R4 REST interactions](https://hl7.org/fhir/R4/http.html).
This is a configured HTTP proxy, not a FHIR implementation, payload/profile
validator or SMART-on-FHIR authorization server. The backend remains responsible
for resource/patient permissions, consent, identity context, search filtering,
validation, clinical audit, persistence and its actual CapabilityStatement.
Token verification alone does not implement those controls.

`enable_queue=true` creates an independently enabled Queue with an existing KMS
key, 24-hour default retention, 60-second visibility timeout and native dead-letter
settings after five delivery attempts. No API-to-Queue binding, message producer,
consumer, replay job, HL7 v2 listener or transformation Function is created.
The integration subnet/NSG is an explicit handoff for separately deployed workers;
only OSN HTTPS egress is granted to that NSG, with no inbound listener by default.
Oracle lists Queue API in its [SGW-supported services](https://www.oracle.com/cloud/networking/private-service-access/service-gateway-and-psa-supported-services/);
verify the selected regional endpoint and actual private access before acceptance.

## Existing Hospital Systems And Data Project

Supply an approved FHIR server URL and its private prefixes. It may be hosted in
the hospital, an approved existing project or another separately designed cloud
foundation. No unknown external-cloud resources are inferred from a URL.

The companion patient-data project provides an application/data foundation, but
it does not install a FHIR server or establish database compatibility for a chosen
FHIR engine. The two example VCNs differ (10.120/16 and 10.121/16); connecting them
still requires deliberate DRG routing, matching access controls, DNS and a reviewed
backend service. No database replication or automatic clinical-record exchange
is configured between the blueprints.

## Integration And Security Contract

See [hospital integration handoffs](integration/README.md). Endpoint enablement
requires `fhir_backend_authorization_ready=true`, which records an operator
acknowledgement rather than verifying backend authorization. Test identity-header
propagation, audience compatibility and direct-backend bypass controls before
acceptance. A dynamic `/{id}` path is not an operation denylist; the backend must
validate logical IDs and reserved operation paths against its authorization rules.

No API response cache or request-body logging configuration is created. Network
flow logs are not clinical audit events. Review identifiers/search parameters,
backend logs, queue payloads, redaction, consent and retention before handling real
records. Prefer reference events over unapproved copies of complete patient data.
No particular jurisdiction, retention obligation or regulatory certification is assumed.

## Local Workflow

```bash
cd blueprints/industry/healthcare-fhir-integration
cp terraform.tfvars.example terraform.tfvars
terraform init -backend=false
terraform validate
terraform test
terraform plan
```

The example is review-only. Use the shared Ansible plan/apply/destroy wrappers
only after approving a real plan and the intended deployment scope. No apply or
clinical transaction was performed while creating the blueprint. Keep secrets,
patient data and deployment state out of Git.

[Architecture](architecture/README.md) includes all declared resources and
explicit external connectors. [Validation evidence](../../../docs/HEALTHCARE-FHIR-20261028.md)
separates local configuration tests from operational and clinical acceptance.
