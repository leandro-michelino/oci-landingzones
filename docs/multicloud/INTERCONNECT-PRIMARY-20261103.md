# Interconnect-primary architecture update — 2026-11-03

## Changes and ownership

- AWS hybrid overview now recommends native managed Interconnect for OCI Ashburn / AWS N. Virginia, distinguishes conventional carrier Direct Connect/FastConnect and documents external DXGW/TGW attachment prerequisites. New `managed-interconnect` contract mode records the existing AWS managed ID separately from a conventional Direct Connect connection ID and rejects other native region pairs in this dated implementation.
- Azure hybrid overview recommends FastConnect/ExpressRoute primary with independently configured optional VPN, lists ExpressRoute gateway and circuit prerequisites and uses Johannesburg / South Africa North as a supported example.
- Google hybrid and dedicated overviews distinguish redundant Partner Interconnect from the optional independent HA VPN. The Google overview labels Cloud Router associations as control plane, and uses Madrid as a supported example.
- The [region matrix](INTERCONNECT-REGIONS.md) records 1 AWS pair, 12 Azure OCI connection locations and 14 Google commercial pairs with official references and transit limitations.
- AWS and Azure subnet routes now include approved remote prefixes in dedicated mode even when VPN is disabled. Circuit ownership, source defaults, existing cloud states and VPN-only defaults are retained. ID contracts do not inspect or provision external primary circuits. No state migration is implied.
- Five overview draw.io/PNG pairs and resource/input companion pages are synchronized with their generators and source inventories. AWS dedicated example now uses the documented native region pair while creation remains disabled. Catalog entries and walkthrough pages reflect the revised recommendation.

## Local validation

Date: 2026-11-03. OCI provider 9.11.0, AWS provider 6.70.0, Google provider 7.46.2 for both Google roots. No credentials or live cloud resources were needed.

| Root | Terraform validate | Mock plan cases |
| --- | --- | --- |
| AWS hybrid | Passed | 5 passed |
| Azure dual connectivity | Passed | 3 passed |
| AWS managed Interconnect | Passed | 9 passed |
| Google Partner Interconnect | Passed | 11 passed |
| Google hybrid OCI root | Passed | 3 passed |
| Google hybrid Google root | Passed | 6 passed |

All **37 mocked plans** passed. Regression assertions cover dedicated-mode remote-prefix routes with VPN disabled, managed AWS region rejection, existing VCN/DRG attachment behavior and existing dedicated/VPN guards. One initial new assertion attempted to count a set containing unknown gateway IDs during plan; it was changed to inspect the known remote destination, and the AWS suite then passed. This was a test-expression issue; no cloud apply was attempted.

Terraform formatting and schema validation passed for all six roots. Diagram layout checks and visual review passed for the five overview renders. Source-to-diagram inventory checks passed for 124 resource declarations across the five blueprints. Native XML checks passed for unique page-local IDs and connector/parent references on 45 pages (combined documents and companion files). Six resource-parser regression tests and local Markdown link checks passed. Repository documentation, naming and generated-catalog checks passed after regenerating BLUEPRINTS.md.

Historical live-lifecycle evidence in the blueprint headers is unchanged. Nothing here establishes live provider entitlement, circuit activation, BGP health, packet delivery, encryption, latency, throughput or failover. No cloud resources were provisioned and no live cleanup was required. Production cost and activation approvals remain separate.
