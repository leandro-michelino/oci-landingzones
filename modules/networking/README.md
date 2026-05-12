# Networking Modules

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This directory groups reusable modules for OCI network foundations. The folder
does not deploy resources by itself; use the modules from a networking
blueprint or from a higher-level landing-zone blueprint.

## Modules

- `hub-vcn/` and `spoke-vcn/` - VCN, subnet, route-table, security-list, and gateway foundations.
- `drg/` - dynamic routing gateway attachments and route distributions.
- `dns/` - private DNS zones, views, and resolvers.
- `ipsec-vpn/` - customer-premises equipment and IPSec connections.
- `fastconnect/` - virtual circuit foundations.
- `net-firewall/` - OCI Network Firewall foundations.
- `net-appliance/` - network virtual appliance foundations.
- `zpr/` - Zero Trust Packet Routing security attributes and policies.

## Usage Notes

- External connectivity modules are disabled by default in generic examples and require explicit real environment inputs.
- Keep CIDR, routing, and DNS ownership decisions in blueprint variables or ignored tfvars files.
- Review each child module README for inputs, outputs, and opt-in behavior.
