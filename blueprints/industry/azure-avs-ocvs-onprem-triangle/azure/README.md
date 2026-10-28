# Azure VMware Companion

Deploy this template separately to an explicitly selected dedicated resource group.
No Azure calls or deployments were made during local template compilation.

All resource creation is disabled by default. `costsApproved`,
`regionPairVerified` and `addressPlanVerified` must be true before any AVS or
ExpressRoute creation. `connectAvsToOci` additionally needs
`createInterconnectCircuit=true` and `avsTransitVerified=true`. The output
`effectiveFlags` shows which branches are selected; flags blocked by prerequisites
create nothing. Select an eligible classic AVS SKU/region, host count and
non-overlapping /22 management block; example AV36 and 10.180.0.0/22 are not
availability or sizing commitments. Subscription quota/host entitlement is external.

The template can create AVS or attach to an existing same-resource-group private
cloud by keeping `createPrivateCloud=false`. Do not enable AVS creation against
an already externally owned name without a separate ownership/adoption review.
The HCX add-on needs explicit supported offer, management and uplink network
inputs. No HCX credentials, site pairing, service mesh or workload is created.

The Oracle-facing ExpressRoute circuit is customer-owned. Its service key must
be retrieved privately and copied into OCI `circuits.azure.service_key`.
Use Oracle's setup sequence for the two BGP address pairs and automatic Azure
private-peering completion. Match bandwidth on both sides. Wait for both circuit
providers to report provisioning and verify private peering before enabling the
AVS Global Reach attachment. Its authorization is created on the Oracle-facing
circuit; no key or administrator password is emitted as an output.

Global Reach availability and eligibility for the selected AVS/Oracle circuit
pair are NOT established by template compilation. Keep `avsTransitVerified=false`
until Microsoft/Oracle confirm the proposed pairing. An AVS managed circuit is
part of the AVS service, not an independently created customer ER resource.
No VNet, virtual network gateway or assumed circuit-to-circuit gateway transit
is created in this variant.

In the triangle, `connectOnpremToAvs` creates a separate Global Reach attachment
to the supplied existing on-premises carrier circuit only when
`onpremGlobalReachVerified=true`. Obtain its circuit ID and authorization key
securely from its owner; this template does not provision the carrier circuit.
The on-premises carrier circuit is different from the Oracle-facing circuit.

Use the sibling `ansible/azure-plan.yml` / `azure-apply.yml` / `azure-destroy.yml`
with explicit AZURE_VMWARE_RESOURCE_GROUP, LOCATION and PARAMETERS_FILE selections.
The shared destroy runner deletes the ENTIRE selected resource group, including
unrelated resources. Use a dedicated group, review its inventory and remove
external/global-reach dependencies first; do not run it against a shared group.
Runtime what-if, provider permissions and cloud deployment have not been tested.

[Architecture](../architecture/README.md) · [Runbook](../../../../docs/multicloud/VMWARE-HYBRID.md)

## Explicit Customer Circuit In The Diagram

The overview now gives the existing customer ExpressRoute circuit its own icon
and connectors: customer edge to carrier circuit, circuit ID/authorization to
the optional `onprem-direct` Global Reach resource, and that resource to the
AVS-managed circuit. This is the direct customer–Azure/AVS leg, independent of
both the onprem–OCI circuit and the Oracle-facing Azure circuit. Resource
creation conditions and ownership are unchanged; no VNet gateway or new carrier
circuit resource is inferred from this diagram clarification.
