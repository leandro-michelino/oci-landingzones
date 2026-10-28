# Healthcare Platform Landing Zone

A private OCI patient-data project foundation for patient-facing or hospital-internal
application services and clinical data. It creates application infrastructure
from approved customer images; it does not implement a clinical product.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/industry/healthcare-platform` |
| Best fit | Private hospital applications, patient-service backends and encrypted document/data foundations. |
| Terraform shape | Private VCN/subnets, NSGs, service gateway, optional existing-DRG attachment, flow logs, internal HTTPS LB, Compute, Autonomous Database and Object Storage. |
| Default posture | All cloud creation disabled; explicit compartment and cost approval required. |
| Existing prerequisites | Hospital transport/DRG, KMS key and permissions, VM backup policy, approved app images/ADs, TLS material and backend CA IDs. |
| Related pattern | [Healthcare PCI guardrails](../../compliance/healthcare-pci/README.md) supplies separate optional controls, not this application foundation. |

## Project Scope

The assumed project is a private application and data platform. The three tiers
are ingress, application and database. Documents use Object Storage over the
regional Oracle Services Network. Clinical users reach the internal load
balancer through separately configured hospital connectivity and DNS.

The blueprint creates no Internet Gateway, NAT, public VM IP or public load
balancer. It does not create a DRG or circuit: `drg_id` refers to an existing DRG;
when supplied, Terraform creates the VCN attachment and explicit hospital routes.
DRG import/export policy, remote transport, return routes and hospital DNS are
operator prerequisites, not proven by the attachment.

## Delivery Modes

| Mode | Settings | Result |
| --- | --- | --- |
| Review only | All enable flags false | Local guard contract only; no cloud resources. |
| Private foundation | `enable_foundation=true`, `costs_approved=true` | Three private subnets, empty attached security list, explicit NSGs, OSN service route and three flow-log configurations. |
| Application | Foundation plus `enable_application=true` and all application handoffs | Private Compute nodes, assigned boot backup policy, internal flexible LB, frontend TLS certificate/listener, HTTPS backend set with peer verification and per-node backends. |
| Data services | Foundation plus `enable_database` and/or `enable_documents` | Optional private ADB with mTLS and a versioned, customer-key-encrypted document bucket. |

Workloads require `kms_key_id` and `kms_policies_ready=true`. That acknowledgement
is an operator assertion, not a permission test. No IAM policies, dynamic groups,
Vault, keys, CA, DRG, backup policy or cross-cloud resources are created.

## Application Contract

`application_instances` is a map of approved image IDs and availability domains.
Choose actual shapes/capacity and fault/AD placement for the intended service.
The blueprint does not claim HA from a node count or single-region topology.
Images must already provide a hardened HTTPS service on TCP 443 with a valid
backend certificate. The configured health probe is TCP, not a clinical workflow
or authenticated application check. Supply trusted OCI CA IDs for backend TLS.

The frontend accepts only approved `hospital_client_cidrs`. NSGs permit LB-to-app
443 and app-to-database 1522. Applications have regional OSN HTTPS egress; no
Internet default route is added. Private addressing does not replace application
authorization, user authentication, record-level access control or encryption.

Application database drivers, ADB wallets, users/schemas, document SDK calls,
instance-principal authorization, SSO/MFA and clinical audit events remain
application/operator work. Application logs are not automatically collected.
VCN flow logs capture network metadata and do not establish patient-access audit
coverage. Oracle documents link-local platform-traffic exceptions to NSG/security
list filtering; see [security rules](https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/securityrules.htm)
and [VCN DNS](https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/dns.htm).

## Data And Recovery

ADB defaults request 2 ECPUs, 1 TB, paid License Included, autoscaling off and
31-day automated backup retention. These are editable example allocations,
not a workload sizing result, regional availability check or cost estimate.
ADB uses a private endpoint and requires mTLS. Compute boot volumes, ADB and the
document bucket reference the supplied customer-managed KMS key.

The bucket has `NoPublicAccess` and versioning. This prevents anonymous access;
it does not restrict authorized API requests to the VCN. Network-source/IAM
policy design and service-principal KMS permissions must be supplied separately.
No object retention lock, lifecycle deletion, cross-region replication, secondary
database or DR orchestration is enabled. Approve retention and deletion rules for
the actual project. Backup assignment/versioning do not prove a successful restore.

## Local Workflow

```bash
cd blueprints/industry/healthcare-platform
cp terraform.tfvars.example terraform.tfvars
terraform init -backend=false
terraform validate
terraform test
terraform plan
```

Alternatively use `ansible/plan.yml`, `ansible/apply.yml` and `ansible/destroy.yml`
with the shared repository runner. Review the full plan before authorizing an
apply. No apply was performed while creating this blueprint.

Inject secrets through a protected mechanism. Certificate private keys and ADB
ADMIN passwords are sensitive inputs and remain in deployment state. Protect state
and plans; keep real tfvars, credentials, certificates and patient data out of Git.
No patient identifiers should appear in names, tags, metadata or infrastructure logs.

## Acceptance Before A Real Project Launch

- Approve data classification, allowed region, retention/deletion ownership and access roles.
- Confirm hospital connectivity, DRG routing, DNS and private endpoint reachability.
- Verify KMS permissions, image hardening, TLS trust, identity integration and application authorization.
- Exercise database access, document authorization, clinical audit capture and restore/runbook procedures.
- Review availability targets and decide whether a separate DR blueprint is required.

Infrastructure configuration and local tests do not establish regulatory
compliance, clinical safety, application readiness or production certification.
See [architecture and connectors](architecture/README.md) and
[local validation evidence](../../../docs/HEALTHCARE-PLATFORM-20261028.md).

The separate [hospital/FHIR integration blueprint](../healthcare-fhir-integration/README.md)
provides API mediation and optional queue infrastructure. Neither blueprint
automatically installs a FHIR server or connects the two projects.
