# Oracle APEX On Autonomous Database Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This page is the deployment architecture for `blueprints/data-platform/apex-adw`.
It is intentionally ASCII-first so it is easy to review in GitHub, terminals,
pull requests, runbooks, and customer notes without a diagramming tool.

## Deployment Purpose

Adds a private APEX/ORDS access layer and operator hand-off around an existing
Autonomous Database.

## Architecture At A Glance

| Item | Details |
|---|---|
| Boundary | `blueprints/data-platform/apex-adw` owns this deployment folder and its Terraform + Ansible runners. |
| Purpose | Provides private APEX ingress, ORDS backend wiring, optional Vault secret hand-off, and ADB APEX/ORDS outputs. |
| Terraform components | `data.oci_database_autonomous_database.this`, `oci_load_balancer_load_balancer.this`, `oci_load_balancer_backend_set.ords`, `oci_load_balancer_backend.ords`, `oci_load_balancer_listener.https`, `oci_vault_secret.apex_admin` |
| Primary architecture view | The ASCII diagram below shows the OCI components, dependency order, and private request path for this exact deployment. |

## ASCII Architecture

```text
+----------------------------------------------------------------------------------------------------------------+
| Oracle APEX On Autonomous Database                                                                              |
+----------------------------------------------------------------------------------------------------------------+
| Legend: [managed resource]  (supplied/external)  {trust boundary}  -> traffic/control flow                       |
|                                                                                                                |
| [Operator / CI]                                                                                                |
|      |                                                                                                         |
|      | terraform plan/apply or guarded Ansible runner                                                          |
|      v                                                                                                         |
| [Terraform OCI provider]                                                                                       |
|      |                                                                                                         |
|      +--> (existing Autonomous Database OCID)                                                                   |
|      |        |                                                                                                |
|      |        v                                                                                                |
|      |   [ADB data source]                                                                                     |
|      |        |-- APEX URL and ORDS URL                                                                        |
|      |        |-- APEX / ORDS version details                                                                 |
|      |        `-- private endpoint IP when available                                                           |
|      |                                                                                                         |
|      +--> [Vault secret, optional]                                                                              |
|      |        |-- APEX workspace bootstrap payload                                                             |
|      |        |-- admin hand-off material                                                                      |
|      |        `-- encrypted with supplied Vault/KMS key                                                         |
|      |                                                                                                         |
|      `--> [Private flexible load balancer, optional]                                                            |
|               |-- private subnet placement                                                                     |
|               |-- NSGs allow app/admin source ranges only                                                      |
|               |-- HTTPS listener with supplied certificate                                                     |
|               |-- ORDS backend set                                                                             |
|               `-- backend IPs: ADB private endpoint IP or supplied ORDS IPs                                    |
|                       |                                                                                        |
|                       | HTTPS / ORDS                                                                            |
|                       v                                                                                        |
|              (Autonomous Database private endpoint)                                                             |
|                       |                                                                                        |
|                       v                                                                                        |
|              [ORDS on Autonomous Database]                                                                      |
|                       |                                                                                        |
|                       v                                                                                        |
|              [APEX workspace, DBA/APEX bootstrap process]                                                       |
|                                                                                                                |
| Private user path: client -> private DNS -> private load balancer -> ORDS backend -> APEX workspace.           |
| Control path: Terraform reads ADB metadata, creates optional LB/Vault resources, and emits hand-off outputs.   |
| Hand-off: direct APEX/ORDS URLs, private APEX URL, backend set, listener, LB IDs, APEX details, secret ID.     |
+----------------------------------------------------------------------------------------------------------------+
```

## Terraform Components

| Kind | Name | Source Or Role |
|---|---|---|
| Data source | `data.oci_database_autonomous_database.this` | Reads ADB connection URLs, APEX details, compartment, and private endpoint IP. |
| Resource | `oci_load_balancer_load_balancer.this` | Optional private flexible load balancer. |
| Resource | `oci_load_balancer_backend_set.ords` | Backend set for ORDS. |
| Resource | `oci_load_balancer_backend.ords` | ORDS backend IP resources. |
| Resource | `oci_load_balancer_listener.https` | HTTPS listener for private APEX traffic. |
| Resource | `oci_vault_secret.apex_admin` | Optional Vault secret for admin or bootstrap material. |

## Request And Deployment Flow

- Operator supplies an existing Autonomous Database OCID from the ADB blueprint
  outputs or another approved source.
- Terraform reads ADB APEX/ORDS metadata and the private endpoint IP when
  available.
- Terraform optionally creates a private load balancer, backend set, ORDS
  backend IPs, and HTTPS listener.
- Terraform optionally stores APEX admin/bootstrap material in Vault.
- Outputs expose URLs, resource IDs, backend IPs, APEX version details, and
  secret IDs for DBA/APEX and platform teams.

## Traffic And Trust Boundaries

- Control plane traffic is local operator or CI authentication into the OCI
  provider and the Ansible Terraform runner.
- Data plane traffic is private HTTPS traffic from approved clients to the load
  balancer, then to ORDS on the ADB private endpoint.
- Trust boundaries are the tenancy, data-platform compartment, private subnet,
  NSGs, load balancer, ADB private endpoint, Vault, and DNS ownership edge.
- DNS names, certificates, OCIDs, backend IPs, admin usernames, bootstrap
  payloads, and secrets belong in ignored local tfvars or secure pipeline
  variables.

## Detailed Architecture Notes

- Autonomous Database provides the APEX and ORDS runtime. This blueprint does
  not create the database; it wraps the existing database with private ingress
  and operational hand-offs.
- The ADB data source can return `connection_urls.apex_url`,
  `connection_urls.ords_url`, `apex_details`, and `private_endpoint_ip`.
- If `private_endpoint_ip` is not available in the target tenancy, supply
  `autonomous_database_private_endpoint_ip` or explicit `ords_backend_ip_addresses`.
- The listener defaults to HTTPS and therefore requires a certificate when the
  load balancer is enabled.
- Backend SSL verification defaults to `false` because private ADB/ORDS
  certificate validation often needs customer CA decisions. Turn it on when the
  trusted CA path is ready.
- APEX workspace creation remains a DBA/APEX bootstrap step. The blueprint
  stores the material and outputs the names so the process is visible and
  repeatable.

## Operational Boundaries

- Keep customer-specific OCIDs, DNS names, certificates, backend IPs, contacts,
  and secrets in ignored local tfvars or approved pipeline variables.
- Run plan from this blueprint folder so provider files and local Ansible
  runners resolve predictably.
- Treat apply and destroy as approval-gated operations; use the guarded Ansible
  playbooks or a reviewed Terraform workflow.
- Re-check private endpoint IPs, NSGs, certificate rotation, DNS records, Vault
  secret rotation, and APEX workspace ownership whenever inputs change.

## Review Checklist

- Confirm the diagram matches `main.tf`: `data.oci_database_autonomous_database.this`,
  `oci_load_balancer_load_balancer.this`, `oci_load_balancer_backend_set.ords`,
  `oci_load_balancer_backend.ords`, `oci_load_balancer_listener.https`, and
  `oci_vault_secret.apex_admin`.
- Confirm the ADB OCID belongs to the intended environment and compartment.
- Confirm private APEX traffic should flow through the selected load balancer
  subnets and NSGs.
- Confirm DNS points to the private load balancer only after the backend health
  check is green.
- Confirm listener certificates and backend SSL verification match the security
  model.
- Confirm Vault secret content is approved and never committed.
- Confirm APEX workspace bootstrap ownership, admin user, and rotation process.
- Confirm `ansible/plan.yml`, `ansible/apply.yml`, and `ansible/destroy.yml`
  still point at the shared Terraform runner.
