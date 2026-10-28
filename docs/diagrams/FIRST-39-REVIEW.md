# Review Of The First 39 Architecture Diagrams

This review covers the fixed set published in commit
`8730634ae09376b0e4cd877226fd9f3b7da2e806`, before the subsequent data-platform
batch. The [scope manifest](../../scripts/diagrams/first-39-review.json) preserves
the original batch order. Review date: October 28, 2026.

All 39 native documents now include their topology overview and complete resource
and prerequisite-reference pages. Azure and AWS declarations use provider icons;
OCI uses the Oracle v24.2 toolkit. No GCP declarations exist in this scope.
Unmapped types, associations and local contracts remain explicitly named.

The source inventory follows pinned module revisions, including disabled resource
branches. Resource pages contain at most 18 declaration cards each. Separate
reference pages document existing-resource/override identifier inputs without
claiming those resources are created or adopted. A reference-only blueprint has
zero managed resources and retains its external ownership boundary.

Coverage: **697 resource declarations**, **70 resource-detail pages** and **106 identifier-input references** across 39 blueprints. Provider totals: AWS: 17, Azure: 38, Contracts: 21, OCI: 621.

These totals are source declarations, not a Terraform plan, expanded collection
size or live deployment inventory. The overview describes default enablement;
full creation expressions and module context are retained in the inventory.
Read-only data lookups are tracked separately. Null/empty inputs do not establish
that external prerequisites exist. No region, CIDR or provider is invented.

| Original order | Blueprint | Declarations | Resource pages | Input references | Evidence |
| --- | --- | --- | --- | --- | --- |
| 1 | `networking/standalone-three-tier-vcn-defaults` | 7 | 1 | 1 | [Overview](../../blueprints/networking/standalone-three-tier-vcn-defaults/architecture/architecture.png) / [Details](../../blueprints/networking/standalone-three-tier-vcn-defaults/architecture/README.md#resource-detail-and-coverage) / [Inventory](../../blueprints/networking/standalone-three-tier-vcn-defaults/architecture/resource-inventory.json) |
| 2 | `networking/standalone-three-tier-vcn-custom` | 7 | 1 | 1 | [Overview](../../blueprints/networking/standalone-three-tier-vcn-custom/architecture/architecture.png) / [Details](../../blueprints/networking/standalone-three-tier-vcn-custom/architecture/README.md#resource-detail-and-coverage) / [Inventory](../../blueprints/networking/standalone-three-tier-vcn-custom/architecture/resource-inventory.json) |
| 3 | `networking/standalone-three-tier-vcn-zpr` | 9 | 1 | 1 | [Overview](../../blueprints/networking/standalone-three-tier-vcn-zpr/architecture/architecture.png) / [Details](../../blueprints/networking/standalone-three-tier-vcn-zpr/architecture/README.md#resource-detail-and-coverage) / [Inventory](../../blueprints/networking/standalone-three-tier-vcn-zpr/architecture/resource-inventory.json) |
| 4 | `networking/standalone-private-endpoint-only` | 7 | 1 | 1 | [Overview](../../blueprints/networking/standalone-private-endpoint-only/architecture/architecture.png) / [Details](../../blueprints/networking/standalone-private-endpoint-only/architecture/README.md#resource-detail-and-coverage) / [Inventory](../../blueprints/networking/standalone-private-endpoint-only/architecture/resource-inventory.json) |
| 5 | `networking/externally-managed-vcns` | 0 | 0 | 4 | [Overview](../../blueprints/networking/externally-managed-vcns/architecture/architecture.png) / [Details](../../blueprints/networking/externally-managed-vcns/architecture/README.md#resource-detail-and-coverage) / [Inventory](../../blueprints/networking/externally-managed-vcns/architecture/resource-inventory.json) |
| 6 | `networking/hub-spoke-with-drg-and-three-tier-vcns` | 18 | 1 | 1 | [Overview](../../blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns/architecture/architecture.png) / [Details](../../blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns/architecture/README.md#resource-detail-and-coverage) / [Inventory](../../blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns/architecture/resource-inventory.json) |
| 7 | `networking/hub-spoke-with-hub-vcn-ipsec-vpn` | 20 | 2 | 1 | [Overview](../../blueprints/networking/hub-spoke-with-hub-vcn-ipsec-vpn/architecture/architecture.png) / [Details](../../blueprints/networking/hub-spoke-with-hub-vcn-ipsec-vpn/architecture/README.md#resource-detail-and-coverage) / [Inventory](../../blueprints/networking/hub-spoke-with-hub-vcn-ipsec-vpn/architecture/resource-inventory.json) |
| 8 | `networking/hub-spoke-with-hub-vcn-fastconnect-vc` | 19 | 2 | 2 | [Overview](../../blueprints/networking/hub-spoke-with-hub-vcn-fastconnect-vc/architecture/architecture.png) / [Details](../../blueprints/networking/hub-spoke-with-hub-vcn-fastconnect-vc/architecture/README.md#resource-detail-and-coverage) / [Inventory](../../blueprints/networking/hub-spoke-with-hub-vcn-fastconnect-vc/architecture/resource-inventory.json) |
| 9 | `networking/hub-spoke-with-hub-vcn-net-firewall` | 20 | 2 | 2 | [Overview](../../blueprints/networking/hub-spoke-with-hub-vcn-net-firewall/architecture/architecture.png) / [Details](../../blueprints/networking/hub-spoke-with-hub-vcn-net-firewall/architecture/README.md#resource-detail-and-coverage) / [Inventory](../../blueprints/networking/hub-spoke-with-hub-vcn-net-firewall/architecture/resource-inventory.json) |
| 10 | `networking/hub-spoke-with-hub-vcn-net-appliance` | 20 | 2 | 2 | [Overview](../../blueprints/networking/hub-spoke-with-hub-vcn-net-appliance/architecture/architecture.png) / [Details](../../blueprints/networking/hub-spoke-with-hub-vcn-net-appliance/architecture/README.md#resource-detail-and-coverage) / [Inventory](../../blueprints/networking/hub-spoke-with-hub-vcn-net-appliance/architecture/resource-inventory.json) |
| 11 | `networking/hub-spoke-with-fortigate-ha` | 24 | 3 | 2 | [Overview](../../blueprints/networking/hub-spoke-with-fortigate-ha/architecture/architecture.png) / [Details](../../blueprints/networking/hub-spoke-with-fortigate-ha/architecture/README.md#resource-detail-and-coverage) / [Inventory](../../blueprints/networking/hub-spoke-with-fortigate-ha/architecture/resource-inventory.json) |
| 12 | `networking/hub-spoke-with-hub-vcn-bastion-jump-host` | 19 | 2 | 1 | [Overview](../../blueprints/networking/hub-spoke-with-hub-vcn-bastion-jump-host/architecture/architecture.png) / [Details](../../blueprints/networking/hub-spoke-with-hub-vcn-bastion-jump-host/architecture/README.md#resource-detail-and-coverage) / [Inventory](../../blueprints/networking/hub-spoke-with-hub-vcn-bastion-jump-host/architecture/resource-inventory.json) |
| 13 | `networking/hub-spoke-with-transit-routing-nva-ha` | 20 | 2 | 2 | [Overview](../../blueprints/networking/hub-spoke-with-transit-routing-nva-ha/architecture/architecture.png) / [Details](../../blueprints/networking/hub-spoke-with-transit-routing-nva-ha/architecture/README.md#resource-detail-and-coverage) / [Inventory](../../blueprints/networking/hub-spoke-with-transit-routing-nva-ha/architecture/resource-inventory.json) |
| 14 | `networking/hub-spoke-with-private-dns-split-horizon` | 22 | 2 | 1 | [Overview](../../blueprints/networking/hub-spoke-with-private-dns-split-horizon/architecture/architecture.png) / [Details](../../blueprints/networking/hub-spoke-with-private-dns-split-horizon/architecture/README.md#resource-detail-and-coverage) / [Inventory](../../blueprints/networking/hub-spoke-with-private-dns-split-horizon/architecture/resource-inventory.json) |
| 15 | `networking/hub-spoke-with-zpr-micro-segmentation` | 20 | 2 | 1 | [Overview](../../blueprints/networking/hub-spoke-with-zpr-micro-segmentation/architecture/architecture.png) / [Details](../../blueprints/networking/hub-spoke-with-zpr-micro-segmentation/architecture/README.md#resource-detail-and-coverage) / [Inventory](../../blueprints/networking/hub-spoke-with-zpr-micro-segmentation/architecture/resource-inventory.json) |
| 16 | `networking/hub-spoke-with-dual-region-dr` | 36 | 2 | 2 | [Overview](../../blueprints/networking/hub-spoke-with-dual-region-dr/architecture/architecture.png) / [Details](../../blueprints/networking/hub-spoke-with-dual-region-dr/architecture/README.md#resource-detail-and-coverage) / [Inventory](../../blueprints/networking/hub-spoke-with-dual-region-dr/architecture/resource-inventory.json) |
| 17 | `networking/multi-tenancy-shared-services` | 22 | 2 | 1 | [Overview](../../blueprints/networking/multi-tenancy-shared-services/architecture/architecture.png) / [Details](../../blueprints/networking/multi-tenancy-shared-services/architecture/README.md#resource-detail-and-coverage) / [Inventory](../../blueprints/networking/multi-tenancy-shared-services/architecture/resource-inventory.json) |
| 18 | `networking/hub-spoke-with-multicloud-interconnect` | 21 | 2 | 2 | [Overview](../../blueprints/networking/hub-spoke-with-multicloud-interconnect/architecture/architecture.png) / [Details](../../blueprints/networking/hub-spoke-with-multicloud-interconnect/architecture/README.md#resource-detail-and-coverage) / [Inventory](../../blueprints/networking/hub-spoke-with-multicloud-interconnect/architecture/resource-inventory.json) |
| 19 | `networking/aws-oci-hybrid-network-backbone` | 30 | 3 | 5 | [Overview](../../blueprints/networking/aws-oci-hybrid-network-backbone/architecture/architecture.png) / [Details](../../blueprints/networking/aws-oci-hybrid-network-backbone/architecture/README.md#resource-detail-and-coverage) / [Inventory](../../blueprints/networking/aws-oci-hybrid-network-backbone/architecture/resource-inventory.json) |
| 20 | `networking/azure-oci-dual-connectivity` | 25 | 3 | 5 | [Overview](../../blueprints/networking/azure-oci-dual-connectivity/architecture/architecture.png) / [Details](../../blueprints/networking/azure-oci-dual-connectivity/architecture/README.md#resource-detail-and-coverage) / [Inventory](../../blueprints/networking/azure-oci-dual-connectivity/architecture/resource-inventory.json) |
| 21 | `networking/azure-vwan-oci-drg-transit` | 29 | 3 | 6 | [Overview](../../blueprints/networking/azure-vwan-oci-drg-transit/architecture/architecture.png) / [Details](../../blueprints/networking/azure-vwan-oci-drg-transit/architecture/README.md#resource-detail-and-coverage) / [Inventory](../../blueprints/networking/azure-vwan-oci-drg-transit/architecture/resource-inventory.json) |
| 22 | `networking/regional-prod-nonprod-hubs` | 36 | 2 | 1 | [Overview](../../blueprints/networking/regional-prod-nonprod-hubs/architecture/architecture.png) / [Details](../../blueprints/networking/regional-prod-nonprod-hubs/architecture/README.md#resource-detail-and-coverage) / [Inventory](../../blueprints/networking/regional-prod-nonprod-hubs/architecture/resource-inventory.json) |
| 23 | `networking/network-load-balancer` | 5 | 1 | 5 | [Overview](../../blueprints/networking/network-load-balancer/architecture/architecture.png) / [Details](../../blueprints/networking/network-load-balancer/architecture/README.md#resource-detail-and-coverage) / [Inventory](../../blueprints/networking/network-load-balancer/architecture/resource-inventory.json) |
| 24 | `networking/hub-spoke-with-azure-vwan-expressroute` | 31 | 4 | 7 | [Overview](../../blueprints/networking/hub-spoke-with-azure-vwan-expressroute/architecture/architecture.png) / [Details](../../blueprints/networking/hub-spoke-with-azure-vwan-expressroute/architecture/README.md#resource-detail-and-coverage) / [Inventory](../../blueprints/networking/hub-spoke-with-azure-vwan-expressroute/architecture/resource-inventory.json) |
| 25 | `core` | 29 | 2 | 6 | [Overview](../../blueprints/core/architecture/architecture.png) / [Details](../../blueprints/core/architecture/README.md#resource-detail-and-coverage) / [Inventory](../../blueprints/core/architecture/resource-inventory.json) |
| 26 | `cis/level1` | 29 | 2 | 4 | [Overview](../../blueprints/cis/level1/architecture/architecture.png) / [Details](../../blueprints/cis/level1/architecture/README.md#resource-detail-and-coverage) / [Inventory](../../blueprints/cis/level1/architecture/resource-inventory.json) |
| 27 | `cis/level2` | 29 | 2 | 4 | [Overview](../../blueprints/cis/level2/architecture/architecture.png) / [Details](../../blueprints/cis/level2/architecture/README.md#resource-detail-and-coverage) / [Inventory](../../blueprints/cis/level2/architecture/resource-inventory.json) |
| 28 | `identity/cis-basic` | 3 | 1 | 1 | [Overview](../../blueprints/identity/cis-basic/architecture/architecture.png) / [Details](../../blueprints/identity/cis-basic/architecture/README.md#resource-detail-and-coverage) / [Inventory](../../blueprints/identity/cis-basic/architecture/resource-inventory.json) |
| 29 | `identity/new-identity-domain` | 2 | 1 | 1 | [Overview](../../blueprints/identity/new-identity-domain/architecture/architecture.png) / [Details](../../blueprints/identity/new-identity-domain/architecture/README.md#resource-detail-and-coverage) / [Inventory](../../blueprints/identity/new-identity-domain/architecture/resource-inventory.json) |
| 30 | `identity/custom-identity-domain` | 2 | 1 | 1 | [Overview](../../blueprints/identity/custom-identity-domain/architecture/architecture.png) / [Details](../../blueprints/identity/custom-identity-domain/architecture/README.md#resource-detail-and-coverage) / [Inventory](../../blueprints/identity/custom-identity-domain/architecture/resource-inventory.json) |
| 31 | `operating-entity` | 4 | 1 | 2 | [Overview](../../blueprints/operating-entity/architecture/architecture.png) / [Details](../../blueprints/operating-entity/architecture/README.md#resource-detail-and-coverage) / [Inventory](../../blueprints/operating-entity/architecture/resource-inventory.json) |
| 32 | `operating-entity/multi-operating-entities` | 4 | 1 | 1 | [Overview](../../blueprints/operating-entity/multi-operating-entities/architecture/architecture.png) / [Details](../../blueprints/operating-entity/multi-operating-entities/architecture/README.md#resource-detail-and-coverage) / [Inventory](../../blueprints/operating-entity/multi-operating-entities/architecture/resource-inventory.json) |
| 33 | `operating-entity/workload-vending` | 4 | 1 | 2 | [Overview](../../blueprints/operating-entity/workload-vending/architecture/architecture.png) / [Details](../../blueprints/operating-entity/workload-vending/architecture/README.md#resource-detail-and-coverage) / [Inventory](../../blueprints/operating-entity/workload-vending/architecture/resource-inventory.json) |
| 34 | `compliance/scca-cloud-native` | 51 | 3 | 3 | [Overview](../../blueprints/compliance/scca-cloud-native/architecture/architecture.png) / [Details](../../blueprints/compliance/scca-cloud-native/architecture/README.md#resource-detail-and-coverage) / [Inventory](../../blueprints/compliance/scca-cloud-native/architecture/resource-inventory.json) |
| 35 | `compliance/zero-trust` | 38 | 3 | 3 | [Overview](../../blueprints/compliance/zero-trust/architecture/architecture.png) / [Details](../../blueprints/compliance/zero-trust/architecture/README.md#resource-detail-and-coverage) / [Inventory](../../blueprints/compliance/zero-trust/architecture/resource-inventory.json) |
| 36 | `compliance/healthcare-pci` | 4 | 1 | 3 | [Overview](../../blueprints/compliance/healthcare-pci/architecture/architecture.png) / [Details](../../blueprints/compliance/healthcare-pci/architecture/README.md#resource-detail-and-coverage) / [Inventory](../../blueprints/compliance/healthcare-pci/architecture/resource-inventory.json) |
| 37 | `compliance/security-posture` | 8 | 1 | 12 | [Overview](../../blueprints/compliance/security-posture/architecture/architecture.png) / [Details](../../blueprints/compliance/security-posture/architecture/README.md#resource-detail-and-coverage) / [Inventory](../../blueprints/compliance/security-posture/architecture/resource-inventory.json) |
| 38 | `disaster-recovery/fsdr` | 5 | 1 | 3 | [Overview](../../blueprints/disaster-recovery/fsdr/architecture/architecture.png) / [Details](../../blueprints/disaster-recovery/fsdr/architecture/README.md#resource-detail-and-coverage) / [Inventory](../../blueprints/disaster-recovery/fsdr/architecture/resource-inventory.json) |
| 39 | `disaster-recovery/azure-oci-cross-cloud-dr` | 18 | 3 | 3 | [Overview](../../blueprints/disaster-recovery/azure-oci-cross-cloud-dr/architecture/architecture.png) / [Details](../../blueprints/disaster-recovery/azure-oci-cross-cloud-dr/architecture/README.md#resource-detail-and-coverage) / [Inventory](../../blueprints/disaster-recovery/azure-oci-cross-cloud-dr/architecture/resource-inventory.json) |

## Reproduction And Static Checks

Regenerate a changed overview with its original authoring script, then run:

```bash
python3 scripts/diagrams/multicloud-resource-coverage.py --first-39 --render
python3 scripts/diagrams/review-first-39.py --write-report
python3 scripts/diagrams/test_resource_coverage.py
bash scripts/check-repo-contracts.sh
```

The [machine-readable static review](review-first-39.json) records layout results,
source/inventory coverage and PNG hashes. The review checks every overview against
its authoring script, main-document page/card labels, cloud-specific icon mappings,
embedded SVG syntax, complete source expressions/module context and PNG presence.
Regression checks prevent a nested dynamic-block collection from being mistaken
for a resource-level creation gate or leaking from another root block.

All PNGs were visually reviewed after export. This is documentation validation.
No provisioning, provider upgrade/revalidation, traffic test, login test, security
assessment, compliance certification, replication test or recovery drill was run.
Historical Terraform/provider success metadata remains unchanged.

Overall conversion progress remains **44 of 80**, with **36** pending. This review
improves the original 39 diagrams; it does not count them as new conversions.
