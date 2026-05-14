# OCI Container Instances Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/extensions/container-instances`. It is intentionally ASCII-first so it is easy to review in GitHub, terminals, pull requests, runbooks, and customer notes without a diagramming tool.

## Deployment Purpose

Deploys a private OCI Container Instance runtime with VNIC, container definitions, optional pull secrets, optional volumes, and optional scoped IAM policy.

## Architecture At A Glance

| Item | Details |
|---|---|
| Boundary | `blueprints/extensions/container-instances` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Runs one or more approved container images without an OKE cluster. |
| Terraform components | `oci_container_instances_container_instance.this`, `oci_identity_policy.access` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and traffic or control flow for this exact deployment. |

## ASCII Architecture

```text
+----------------------------------------------------------------------------------------------------------+
| OCI Container Instances                                                                                  |
+----------------------------------------------------------------------------------------------------------+
| Legend: [managed resource]  (supplied/external)  {trust boundary}  -> traffic/control flow               |
|                                                                                                          |
| [Operator / CI] -> [blueprint-local Ansible runner] -> [Terraform OCI provider]                          |
|         |                    |                         |                                                 |
|         | validates docs      | init/validate/plan      | OCI API calls                                  |
|         v                    v                         v                                                 |
| {App compartment / selected availability domain}                                                         |
|         |                                                                                                |
|         +--> (private subnet)                                                                            |
|         |        |                                                                                       |
|         |        v                                                                                       |
|         |   [Container Instance VNIC]                                                                    |
|         |        |-- NSGs allow approved app, service, and admin paths only                              |
|         |        `-- public IP disabled by default                                                       |
|         |                                                                                                |
|         +--> [Container Instance]                                                                        |
|         |        |-- container image from OCIR or approved registry                                      |
|         |        |-- optional image pull secret from Vault or local secure input                         |
|         |        |-- optional health checks and resource limits                                         |
|         |        `-- optional config or empty volumes                                                    |
|         |                                                                                                |
|         `--> [IAM access policy]                                                                         |
|                  optional operator or service-principal statements                                       |
|                                                                                                          |
| Runtime path: app callers -> NSG-approved private IP -> container listener.                              |
| Image path: container runtime -> registry endpoint using approved pull secret when needed.                |
| Hand-off: container instance ID, VNIC IDs, container IDs, state, and optional access policy ID.           |
+----------------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
|---|---|---|
| Resource | `oci_container_instances_container_instance.this` | Declared directly in `main.tf` |
| Resource | `oci_identity_policy.access` | Optional scoped IAM policy declared directly in `main.tf` |

## Request And Deployment Flow

- Operator supplies tenancy values, availability domain, private subnet, NSGs, and approved container image details.
- Terraform creates the Container Instance, VNIC, container definitions, optional pull secrets, optional volumes, and optional IAM policy.
- Outputs expose runtime IDs, VNIC IDs, container IDs, state, and policy ID for app teams and runbooks.

## Traffic And Trust Boundaries

- Control plane traffic is local operator or CI authentication into the OCI provider and the Ansible Terraform runner.
- Data plane traffic enters the Container Instance through the VNIC private IP and NSG-approved paths.
- Image pull traffic goes from the runtime to OCIR or an approved registry endpoint using the configured image pull secret when needed.
- Trust boundaries are the tenancy, compartment, private subnet, VNIC, NSG, image registry, Vault secret, and IAM policy edges shown in the diagram.
- Secrets, OCIDs, customer CIDRs, image credentials, endpoint URLs, and contact data belong in ignored local tfvars or a secure pipeline variable store, not in committed files.

## Detailed Architecture Notes

- Keep public IP assignment disabled unless the design explicitly needs a public runtime endpoint.
- Prefer private subnets and NSGs that only allow source CIDRs or application tiers that need the container listener.
- Prefer Vault-backed registry secrets over inline pull passwords.
- Use health checks and container resource limits for long-running service containers.
- Use optional IAM policy statements only when the runtime or operators need additional OCI permissions.

## Operational Boundaries

- This extension can run extension-only with supplied brownfield OCI IDs, or as
  base-plus-extension using outputs from core, networking, ownership, or
  operations blueprints.
- Keep customer-specific OCIDs, CIDRs, DNS names, endpoints, contacts, and secrets in ignored local tfvars or approved pipeline variables.
- Run plan from this blueprint folder so relative module paths, provider files, and local Ansible runners resolve predictably.
- Treat apply and destroy as approval-gated operations; use the guarded Ansible playbooks or a reviewed Terraform workflow.
- Re-check route exposure, IAM scope, compartment boundaries, tags, and output hand-offs whenever inputs change.

## Review Checklist

- Confirm the diagram matches `main.tf`: `oci_container_instances_container_instance.this`, `oci_identity_policy.access`.
- Confirm the described traffic or control path is the path you want in OCI before apply.
- Confirm public exposure, private endpoint access, DNS behavior, DRG routing, and inspection points are intentional where present.
- Confirm IAM scopes, compartment boundaries, tags, and operational outputs match the deployment README.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml` still point at the shared Terraform runner.
