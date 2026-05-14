# Network Load Balancer Landing Zone Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

## Deployment Purpose

This blueprint implements an OCI Network Load Balancer pattern for Layer 4
traffic. It handles private or public NLB placement, backend sets, backend
registrations, health checks, listeners, source preservation options, and IAM.

## Architecture At A Glance

| Layer | Components |
| --- | --- |
| Entry | OCI Network Load Balancer in selected subnet. |
| Listener | TCP, UDP, or supported L4 listener ports. |
| Routing | Backend sets with health checks and load-balancing policy. |
| Targets | IP or target OCID backends in private application subnets. |
| Governance | NSGs, tags, IAM policy shell, and operator review. |

## ASCII Architecture

```text
+--------------------------------------------------------------------------------+
|                    Network Load Balancer Landing Zone                           |
+--------------------------------------------------------------------------------+
|                                                                                |
|  Client / Producer                                                             |
|      |                                                                         |
|      | TCP, UDP, or other L4 protocol                                          |
|      v                                                                         |
|  OCI Network Load Balancer                                                     |
|      |                                                                         |
|      +--> Listener tcp_8080                                                    |
|      +--> Listener udp_9000 optional                                           |
|      +--> Private or public IP based on approved exposure                      |
|      |                                                                         |
|      v                                                                         |
|  Backend Sets                                                                  |
|      |                                                                         |
|      +--> Policy: five tuple / two tuple / three tuple                         |
|      +--> Health checker: TCP, HTTP, or HTTPS                                  |
|      +--> Fail-open and source preservation options                            |
|      |                                                                         |
|      v                                                                         |
|  Private Backend Targets                                                       |
|      |                                                                         |
|      +--> Compute private IPs                                                  |
|      +--> Database or appliance endpoints                                      |
|      +--> Container or app tier endpoints                                      |
|      `--> Drain, offline, backup, and weight controls                          |
|                                                                                |
|  Governance Lane                                                               |
|      |                                                                         |
|      +--> NSGs and route table review                                          |
|      +--> IAM for network operators                                            |
|      `--> Tags and output hand-off to application teams                        |
+--------------------------------------------------------------------------------+
```

## Terraform Components

| File | Purpose |
| --- | --- |
| `main.tf` | Creates NLB, backend sets, backends, listeners, and optional IAM policy. |
| `variables.tf` | Defines exposure, subnet, NSG, backend set, backend, listener, and policy contracts. |
| `outputs.tf` | Exposes NLB ID, IPs, backend set names, listeners, and policy output. |
| `terraform.tfvars.example` | Shows a safe private TCP listener example. |

## Request And Deployment Flow

1. Workload owner identifies protocol, port, and backend targets.
2. Network owner chooses private or public placement and NSG model.
3. Health check protocol and backend set policy are reviewed.
4. Terraform creates or references the NLB and adds backend sets.
5. Terraform registers backend targets and listeners.
6. Application owner receives listener and backend set outputs.

## Traffic And Trust Boundaries

- `is_private` defaults to true to avoid accidental public L4 exposure.
- Public NLBs require separate ingress, DNS, and security review.
- Backends should live in private subnets unless a customer exception exists.
- Source preservation changes routing and backend security expectations.
- NSGs and route tables remain the primary network controls around targets.

## Detailed Architecture Notes

- Backend sets and listeners are map-driven so multiple protocols can be
  modeled without new files.
- Backends can be IP-based or target OCID-based depending on workload needs.
- Health checker values stay close to backend set definitions for review.
- Listener `backend_set_key` links to Terraform-created backend sets.
- Existing NLBs can be referenced with `network_load_balancer_id`.
- IAM policy creation is optional because many networking teams centralize it.

## Operational Boundaries

- Terraform does not install or configure backend applications.
- Terraform does not create DNS records or certificates for higher-layer flows.
- Health check behavior should be tested before cutover.
- Backend drain/offline flags are configuration choices, not deployment runbooks.
- Route symmetry and source preservation need customer network validation.

## Review Checklist

- Exposure is private unless public L4 ingress is explicitly approved.
- Listener ports and protocols match the workload.
- Backend targets are correct and reachable.
- Health checks are safe and meaningful.
- NSG and route table changes are reviewed.
- Source preservation settings are understood.
- IAM policy statements are scoped to network operators.
