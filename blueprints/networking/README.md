# Networking blueprints

This directory contains 27 blueprints and one separately executed Google Terraform companion root. Choose the source-defined foundation, then explicitly design/activate the required transport, routing and workloads.

For cross-cloud traffic, prefer Interconnect as primary and independently configured VPN as backup or alternative when Interconnect cannot be used. See the [supported commercial connection locations](../../docs/multicloud/INTERCONNECT-REGIONS.md) and [complete source review and validation matrix](../../docs/NETWORKING-REVIEW-20261103.md).

| Blueprint | Operator guide | Architecture |
| --- | --- | --- |
| aws-oci-hybrid-network-backbone | [Guide](aws-oci-hybrid-network-backbone/README.md) | [Diagram and scope](aws-oci-hybrid-network-backbone/architecture/README.md) |
| aws-oci-managed-interconnect | [Guide](aws-oci-managed-interconnect/README.md) | [Diagram and scope](aws-oci-managed-interconnect/architecture/README.md) |
| azure-oci-dual-connectivity | [Guide](azure-oci-dual-connectivity/README.md) | [Diagram and scope](azure-oci-dual-connectivity/architecture/README.md) |
| azure-vwan-oci-drg-transit | [Guide](azure-vwan-oci-drg-transit/README.md) | [Diagram and scope](azure-vwan-oci-drg-transit/architecture/README.md) |
| externally-managed-vcns | [Guide](externally-managed-vcns/README.md) | [Diagram and scope](externally-managed-vcns/architecture/README.md) |
| gcp-oci-hybrid-network-backbone | [Guide](gcp-oci-hybrid-network-backbone/README.md) | [Diagram and scope](gcp-oci-hybrid-network-backbone/architecture/README.md) |
| gcp-oci-partner-interconnect | [Guide](gcp-oci-partner-interconnect/README.md) | [Diagram and scope](gcp-oci-partner-interconnect/architecture/README.md) |
| hub-spoke-with-azure-vwan-expressroute | [Guide](hub-spoke-with-azure-vwan-expressroute/README.md) | [Diagram and scope](hub-spoke-with-azure-vwan-expressroute/architecture/README.md) |
| hub-spoke-with-drg-and-three-tier-vcns | [Guide](hub-spoke-with-drg-and-three-tier-vcns/README.md) | [Diagram and scope](hub-spoke-with-drg-and-three-tier-vcns/architecture/README.md) |
| hub-spoke-with-dual-region-dr | [Guide](hub-spoke-with-dual-region-dr/README.md) | [Diagram and scope](hub-spoke-with-dual-region-dr/architecture/README.md) |
| hub-spoke-with-fortigate-ha | [Guide](hub-spoke-with-fortigate-ha/README.md) | [Diagram and scope](hub-spoke-with-fortigate-ha/architecture/README.md) |
| hub-spoke-with-hub-vcn-bastion-jump-host | [Guide](hub-spoke-with-hub-vcn-bastion-jump-host/README.md) | [Diagram and scope](hub-spoke-with-hub-vcn-bastion-jump-host/architecture/README.md) |
| hub-spoke-with-hub-vcn-fastconnect-vc | [Guide](hub-spoke-with-hub-vcn-fastconnect-vc/README.md) | [Diagram and scope](hub-spoke-with-hub-vcn-fastconnect-vc/architecture/README.md) |
| hub-spoke-with-hub-vcn-ipsec-vpn | [Guide](hub-spoke-with-hub-vcn-ipsec-vpn/README.md) | [Diagram and scope](hub-spoke-with-hub-vcn-ipsec-vpn/architecture/README.md) |
| hub-spoke-with-hub-vcn-net-appliance | [Guide](hub-spoke-with-hub-vcn-net-appliance/README.md) | [Diagram and scope](hub-spoke-with-hub-vcn-net-appliance/architecture/README.md) |
| hub-spoke-with-hub-vcn-net-firewall | [Guide](hub-spoke-with-hub-vcn-net-firewall/README.md) | [Diagram and scope](hub-spoke-with-hub-vcn-net-firewall/architecture/README.md) |
| hub-spoke-with-multicloud-interconnect | [Guide](hub-spoke-with-multicloud-interconnect/README.md) | [Diagram and scope](hub-spoke-with-multicloud-interconnect/architecture/README.md) |
| hub-spoke-with-private-dns-split-horizon | [Guide](hub-spoke-with-private-dns-split-horizon/README.md) | [Diagram and scope](hub-spoke-with-private-dns-split-horizon/architecture/README.md) |
| hub-spoke-with-transit-routing-nva-ha | [Guide](hub-spoke-with-transit-routing-nva-ha/README.md) | [Diagram and scope](hub-spoke-with-transit-routing-nva-ha/architecture/README.md) |
| hub-spoke-with-zpr-micro-segmentation | [Guide](hub-spoke-with-zpr-micro-segmentation/README.md) | [Diagram and scope](hub-spoke-with-zpr-micro-segmentation/architecture/README.md) |
| multi-tenancy-shared-services | [Guide](multi-tenancy-shared-services/README.md) | [Diagram and scope](multi-tenancy-shared-services/architecture/README.md) |
| network-load-balancer | [Guide](network-load-balancer/README.md) | [Diagram and scope](network-load-balancer/architecture/README.md) |
| regional-prod-nonprod-hubs | [Guide](regional-prod-nonprod-hubs/README.md) | [Diagram and scope](regional-prod-nonprod-hubs/architecture/README.md) |
| standalone-private-endpoint-only | [Guide](standalone-private-endpoint-only/README.md) | [Diagram and scope](standalone-private-endpoint-only/architecture/README.md) |
| standalone-three-tier-vcn-custom | [Guide](standalone-three-tier-vcn-custom/README.md) | [Diagram and scope](standalone-three-tier-vcn-custom/architecture/README.md) |
| standalone-three-tier-vcn-defaults | [Guide](standalone-three-tier-vcn-defaults/README.md) | [Diagram and scope](standalone-three-tier-vcn-defaults/architecture/README.md) |
| standalone-three-tier-vcn-zpr | [Guide](standalone-three-tier-vcn-zpr/README.md) | [Diagram and scope](standalone-three-tier-vcn-zpr/architecture/README.md) |

Network modules are in [modules/networking](../../modules/networking/). Resource declarations, supplied IDs, mocked checks and verified runtime behavior are separate evidence categories. Consult the review's adoption limits before switching an existing deployment, especially Azure vWAN classic VPN mode or a pinned module revision.
