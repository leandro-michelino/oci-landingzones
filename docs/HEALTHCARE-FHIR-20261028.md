# Hospital/FHIR Integration Local Validation / 2026-10-28

Scope: `blueprints/industry/healthcare-fhir-integration`, oracle/oci 9.11.0.

- Terraform init with backend disabled: passed.
- Terraform validate: passed.
- Eleven mocked plan regressions: passed, zero failures.
- No live plan, apply, token exchange, FHIR transaction, clinical data or hospital API call.

The tests cover disabled defaults, private OSN-only foundation and flow logs,
cost/foundation/identity/backend/KMS gates, CIDR overlap and Internet-prefix
rejection, absence of DELETE routes, issuer/audience/token/JWKS TLS configuration,
optional private-PKI CA bundle references, backend path-parameter binding, GET-only defaults, correct collection versus
instance write-method sets, and encrypted Queue retention/dead-letter settings.

Evidence is reproducible in `tests/configuration-regressions.tftest.hcl`.
Mocked plan success is not identity enforcement, TLS reachability, FHIR conformance,
clinical mapping, restore or interoperability evidence. No cloud resources were
created, so no live cleanup lifecycle was required.

Source decisions were checked against the official
[Oracle token-policy guide](https://docs.oracle.com/en-us/iaas/Content/APIGateway/Tasks/apigatewayusingjwttokens-usinjson.htm),
[HTTP backend guide](https://docs.oracle.com/en-us/iaas/Content/APIGateway/Tasks/apigatewayusinghttpbackend.htm),
[SGW-supported services list](https://www.oracle.com/cloud/networking/private-service-access/service-gateway-and-psa-supported-services/)
and [FHIR R4 HTTP specification](https://hl7.org/fhir/R4/http.html).
The declared route subset does not establish a compliant FHIR implementation.

Diagram delivery: 15 OCI declarations plus two local contracts; two resource maps,
one identifier-reference page and one overview, with all four PNGs inspected.
Five existing-identifier inputs and 16 overview connectors are recorded.
Ansible plan/apply/destroy syntax checks passed; no playbook actions were executed.
