# Extensions Review, October 17, 2026

Catalog items 31-40 were reviewed in order. The only current live fixture used
OCI profile `DEFAULT`, region `sa-saopaulo-1`, and compartment
`ocid1.compartment.oc1..aaaaaaaakezfqoalteuhlhopq7qymraumvajkfgspityukkf7kymzt36vorq`.
The saved plan contained six OCI network resources and two local contracts;
there were no ODA, OKE, API Gateway, Container Instances, Streaming, Exadata,
Functions, Analytics, Object Storage, IAM, DNS, Azure, AWS, or Cloudflare
resources in that plan. Paid service and external-cloud activation remain
outside this round. No estimate or claim about actual account charges is made.

| # | Blueprint | Review outcome | Current validation boundary |
| --- | --- | --- | --- |
| 31 | `extensions/aks-oke-active-passive` | Schema passed. OCI networking, OKE, interconnect, Azure standby, health checks, DNS steering, and failover were not live tested. | Existing private node subnets need an approved egress path before a working node pool can be claimed. |
| 32 | `extensions/apigw` | Schema passed; gateway and deployment remain disabled by default. | No gateway, route, backend, or ingress test. |
| 33 | `extensions/cdn-static-assets` | Changed bucket creation to opt-in. Schema and one mocked default plan passed. | No Object Storage, PAR, Cloudflare, DNS, cache, or delivery test. |
| 34 | `extensions/container-instances` | Schema passed; instance creation remains disabled by default. | No container placement, image pull, or runtime test. |
| 35 | `extensions/digital-assistant` | Corrected endpoint traffic direction, removed the public network path, made service resources opt-in, required an approved backend CIDR, and preserved OCI-managed tags. Schema, three mocked plans, and a reduced six-resource live network lifecycle passed. | No ODA instance, private endpoint, backend connection, or channel test. |
| 36 | `extensions/eks-oke-active-passive` | Schema passed. OCI networking, OKE, interconnect, AWS standby, health checks, DNS steering, and failover were not live tested. | Existing private node subnets need an approved egress path before a working node pool can be claimed. |
| 37 | `extensions/event-driven-platform` | Schema passed; stream, connector, bucket, topic, and event-rule creation remain opt-in. | No current live event delivery, replay, or connector test. Historical May 2026 deployments do not validate this provider revision. |
| 38 | `extensions/exadata` | Schema passed; infrastructure creation remains disabled by default. | No capacity reservation, infrastructure creation, or database test. |
| 39 | `extensions/functions` | Migrated deprecated `image` fields to `source_details`, fixed existing application and gateway ID selection, and passed schema plus three mocked plans without the prior deprecation warning. | No image pull, invocation, gateway, or event test. Existing deployed Functions require a reviewed plan before adoption. |
| 40 | `extensions/oac` | Schema passed; instance and private access channel remain disabled by default. | No analytics instance, PAC, or database connectivity test. |

The ODA private endpoint is for Digital Assistant to reach private backend
services, not for private inbound user or channel access. Oracle's
[service administration documentation](https://docs.oracle.com/en-us/iaas/digital-assistant/doc/service-administration.html)
describes that direction and requires a private subnet for the endpoint. The
new network-only fixture has a private subnet, no internet route, no inbound
security rule, and HTTPS egress restricted to a caller-supplied backend CIDR.
Backends in peered networks or on premises still need separately reviewed
routing and security policy; no packet flow was tested here.

The first ODA live attempt created six network resources, then a refresh plan
showed five updates that would remove OCI-managed `Oracle-Tags` provenance
values. All six resources were destroyed, their IDs were confirmed deleted by
OCI API, and the managed resource state was empty. After the tag fix, a fresh isolated
plan was inspected for resource types, region, compartment, and disabled paid
services. The second attempt created six network resources; live OCI GETs
confirmed them, the next Terraform plan had no changes, and destroy returned
zero managed resources. API deletion checks passed for all six IDs. The final
scoped OCI inventory found zero active VCNs, DRGs, subnets, route tables,
security lists, internet gateways, NAT gateways, service gateways, NSGs, DHCP
options, and network load balancers in the selected compartment, with zero
test leftovers. This is a network-resource inventory, not a billing audit.

All ten blueprints passed `terraform validate`: eight used OCI provider 9.10.0,
while CDN and Event-Driven Platform used their existing 8.21.0 locks.
The new mocked tests added seven passing cases across three files. The full
repository check passed: 80 blueprint schema validations, 277 Ansible syntax
checks, TFLint, Trivy, Checkov (274 passes, zero failures, 13 skips), cloud
deployment simulations, and all pre-commit hooks. Local logs, saved plans,
ID checks, and both
ODA attempts are in ignored `.leo-local/extensions-review-20261017/`.
Do not interpret schema or mocked plans as provisioning or runtime evidence.

Before activating OKE, API Gateway, CDN, Container Instances, Digital
Assistant, Streaming, Exadata, Functions, or Analytics, review the current
[Oracle Cloud price list](https://www.oracle.com/cloud/price-list/) and the
actual selected shape, capacity, traffic, and service limits. Azure, AWS, and
Cloudflare also require separate account and cost review.
