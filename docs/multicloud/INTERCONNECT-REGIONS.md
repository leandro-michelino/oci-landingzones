# OCI multicloud Interconnect: selection and current regions

Availability reviewed **2026-11-03** against the service-specific provider documentation linked below. Commercial public-cloud regions only. These are documented locations, not live account entitlement, capacity or SLA acceptance. Recheck before ordering; this file is a dated snapshot, not an automatic availability feed.

## Design decision

Prefer the native private Interconnect for sustained production cross-cloud traffic when the documented locations, capacity, latency and budget fit. This avoids using public-Internet VPN as the normal data path. It is not universally better: VPN can be suitable for small volumes, temporary migration, unavailable region pairs or a separately engineered backup. Measure application latency and compare port, gateway and traffic charges for the actual workload; no savings or latency figure is assumed here.

| Cloud | Primary design | Resilience and security | Implementation in this repository |
| --- | --- | --- | --- |
| AWS | Oracle Interconnect for AWS / AWS Interconnect, OCI DRG to AWS DXGW | One logical OCI circuit represents managed device/location redundancy and ECMP. MACsec protects the provider edge-to-edge segment; use TLS for application end-to-end protection. | [Managed root](../../blueprints/networking/aws-oci-managed-interconnect/README.md) creates private foundations and requests the OCI side; AWS activation remains an operator step. [Hybrid root](../../blueprints/networking/aws-oci-hybrid-network-backbone/README.md) can reference an existing managed connection, with optional VPN. |
| Azure | FastConnect private VC plus ExpressRoute private peering and ExpressRoute VNet gateway | Built-in redundant BGP sessions in the native connection. Region-level DR is a separate design. Private transport alone does not mean encrypted application traffic. | [Dual-connectivity root](../../blueprints/networking/azure-oci-dual-connectivity/README.md) references existing circuits; its Bicep creates the VPN edge only. [vWAN/ExpressRoute root](../../blueprints/networking/hub-spoke-with-azure-vwan-expressroute/README.md) provides a separate hub deployment option, not an automatic attachment to this VNet. |
| GCP | FastConnect plus Partner Cross-Cloud Interconnect for OCI (Partner VLAN attachments and Cloud Router) | Create two circuits/attachments in distinct edge availability domains; one connection has no built-in redundancy. Review provider topology requirements for the chosen SLA. Use TLS or a reviewed encryption overlay when needed. | [Hybrid root](../../blueprints/networking/gcp-oci-hybrid-network-backbone/README.md) supports two primary circuits and independent HA VPN; [dedicated root](../../blueprints/networking/gcp-oci-partner-interconnect/README.md) omits VPN. |

Cloud Router configures BGP; it is not an inline packet-forwarding appliance. A dedicated Google Cross-Cloud Interconnect port is a different product from this partner offering. Ordinary carrier Direct Connect + FastConnect is also distinct from the native AWS managed product.

**Transit limitation:** the native AWS, Azure and GCP service guides do not support on-premises transit through one cloud to the other. “OCI primary hub” means OCI workload routing ownership, not permission to advertise on-premises prefixes through these connections. Design independent on-premises connectivity to each cloud. Cross-cloud-to-cloud transit also requires its own supported design.

## AWS: one documented commercial region pair

| OCI region | AWS region |
| --- | --- |
| US East (Ashburn), `us-ashburn-1` | US East (N. Virginia), `us-east-1` |

Source: [Oracle Interconnect for AWS availability and setup](https://docs.oracle.com/en-us/iaas/Content/multicloud/interconnect-aws.htm). The API workflow uses a service/activation key and AWS Direct Connect gateway, not a customer-created conventional Direct Connect connection/VIF. Madrid, São Paulo and Johannesburg are not documented native AWS pairs. A provider circuit in other regions requires a separate offering/coverage check.

## Azure: 12 OCI locations and ExpressRoute peering locations

An ExpressRoute **peering location is not an Azure deployment region**. The OCI service guide lists the following connection locations. VNet regional reach depends on ExpressRoute SKU/geopolitical reach and gateway support; do not treat the examples as the exhaustive set of reachable Azure regions.

| OCI region | ExpressRoute peering location | Nearby Azure region example |
| --- | --- | --- |
| `us-ashburn-1` (Ashburn) | Washington DC / Washington DC2 | East US |
| `us-phoenix-1` (Phoenix) | Phoenix | West US 3 |
| `us-sanjose-1` (San Jose) | Silicon Valley | West US |
| `ca-toronto-1` (Toronto) | Toronto / Toronto2 | Canada Central |
| `sa-vinhedo-1` (Vinhedo) | Campinas | Brazil South |
| `eu-frankfurt-1` (Frankfurt) | Frankfurt / Frankfurt2 | Germany West Central |
| `eu-amsterdam-1` (Amsterdam) | Amsterdam2 | West Europe |
| `uk-london-1` (London) | London | UK South |
| `af-johannesburg-1` (Johannesburg) | Johannesburg | South Africa North |
| `ap-tokyo-1` (Tokyo) | Tokyo | Japan East |
| `ap-seoul-1` (Seoul) | Seoul | Korea Central |
| `ap-singapore-1` (Singapore) | Singapore | Southeast Asia |

Sources: [Oracle Azure service guide](https://docs.oracle.com/en-us/iaas/Content/multicloud/interconnect-azure.htm), [Microsoft Oracle/OCI overview](https://learn.microsoft.com/en-us/azure/virtual-machines/workloads/oracle/oracle-oci-overview), [ExpressRoute locations and reach](https://learn.microsoft.com/en-us/azure/expressroute/expressroute-locations-providers).

The general Oracle service-availability marketing table contains inconsistent labels for Singapore and some GCP mappings. This snapshot follows the service-specific Oracle location table and Google's paired-locations table. Verify the regional service entry when ordering rather than copying that marketing table.

## GCP: 14 documented commercial pairs

| OCI region | Google Cloud region |
| --- | --- |
| `ap-tokyo-1` (Tokyo) | `asia-northeast1` |
| `ap-mumbai-1` (Mumbai) | `asia-south1` |
| `ap-singapore-1` (Singapore) | `asia-southeast1` |
| `ap-sydney-1` (Sydney) | `australia-southeast1` |
| `ap-melbourne-1` (Melbourne) | `australia-southeast2` |
| `eu-madrid-1` (Madrid) | `europe-southwest1` |
| `uk-london-1` (London) | `europe-west2` |
| `eu-frankfurt-1` (Frankfurt) | `europe-west3` |
| `eu-zurich-1` (Zurich) | `europe-west6` |
| `ca-montreal-1` (Montréal) | `northamerica-northeast1` |
| `ca-toronto-1` (Toronto) | `northamerica-northeast2` |
| `sa-saopaulo-1` (São Paulo) | `southamerica-east1` |
| `us-ashburn-1` (Ashburn) | `us-east4` |
| `us-phoenix-1` (Phoenix) | `us-west2` |

Sources: [Google paired locations](https://docs.cloud.google.com/network-connectivity/docs/interconnect/how-to/partner-cci-for-oci/paired-locations), [Oracle Google service guide](https://docs.oracle.com/en-us/iaas/Content/multicloud/interconnect-gcp.htm). Government and sovereign clouds are outside this commercial blueprint matrix. Johannesburg is not in this GCP partner list.

## Activation, cutover and rollback

1. Select a supported connection location, approved capacity and non-overlapping ranges. Preserve existing Terraform ownership and state; switching documentation recommendations does not migrate resources.
2. Create or reuse the correct cloud gateways and circuits. AWS: accept the activation key against the intended DXGW and associate VGW/TGW as appropriate. Azure: provision ExpressRoute/private peering, exchange the service key with FastConnect and connect the ExpressRoute gateway to the intended VNet. GCP: exchange both pairing keys, complete partner provisioning, reconcile assigned BGP addresses and activate both attachments.
3. Verify circuit attachment to the **same intended DRG**, route-table associations/import/export filters, remote-prefix routes and symmetric return paths. Circuit ID contracts do not inspect attachment identity or health.
4. Restrict security policies to approved prefixes and application ports. Configure private DNS explicitly. Existing AWS/Azure hybrid demo foundations allow public IPs and Internet defaults; Interconnect does not convert those subnets to private or remove Internet access.
5. Verify BGP, permitted/denied traffic, MTU, throughput and application latency. Exercise single-path loss and full primary-path loss with independently approved workloads before relying on backup routing.
6. Use provider-specific route policy to prefer Interconnect; VPN is optional, separately provisioned and independently tested. AWS/Azure legacy static VPN declarations and Azure BGP/runbook contracts do not configure complete dynamic failover. Do not assume BGP weights or contract values program routing.
7. Retain a reviewed rollback route policy until cutover succeeds. Terminate partner services explicitly during teardown; deleting an identifier contract does not terminate a circuit.

No cloud operations are authorized by these examples. Validation evidence for the source changes is in [the change record](INTERCONNECT-PRIMARY-20261103.md).
