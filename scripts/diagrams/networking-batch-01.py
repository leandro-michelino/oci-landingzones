#!/usr/bin/env python3
"""Networking catalog 1-5, using the installed oci-architecture-diagrams skill.

Requires Oracle's official v24.2 toolkit in OCI_TOOLKIT or the skill toolkit/.
Set OCI_DIAGRAM_SKILL to override ~/.codex/skills/oci-architecture-diagrams.
Run with --render to export PNGs through draw.io Desktop. No cloud operations.
"""
import argparse
import os
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[2]
SKILL = Path(os.environ.get('OCI_DIAGRAM_SKILL', Path.home() / '.codex/skills/oci-architecture-diagrams'))
sys.path.insert(0, str(SKILL / 'scripts'))
from ocidraw import Diagram

TOOLKIT = os.environ.get('OCI_TOOLKIT', str(SKILL / 'toolkit'))
ITEMS = [
    ('standalone-three-tier-vcn-defaults', 'Standalone three-tier VCN | Defaults', '10.10', '80 / 443'),
    ('standalone-three-tier-vcn-custom', 'Standalone three-tier VCN | Custom', '10.20', '443'),
    ('standalone-three-tier-vcn-zpr', 'Standalone three-tier VCN | ZPR option', '10.30', '80 / 443'),
    ('standalone-private-endpoint-only', 'Private endpoint-ready network', '10.20', ''),
    ('externally-managed-vcns', 'Externally managed VCNs | Reference contract', '', ''),
]


def header(title, index):
    d = Diagram(toolkit=TOOLKIT, title=title)
    d.text(title, 20, 10, 1660, 45, size=25, bold=True)
    d.text(f'NETWORKING {index:02} / Oracle OCI Toolkit v24.2 / Blueprint default inputs / Documentation view', 20, 65, 1660, 25, size=13)
    return d


def network(slug, title, prefix, ports, index):
    d = header(title, index)
    private = index == 4
    region = d.group('region', 'OCI Region (operator-selected; deployment value not specified)', 250, 160, 1120, 680)
    comp = d.group('compartment', 'Target compartment (operator input)', 20, 50, 1080, 610, parent=region)
    vcn = d.group('vcn', f'{"Private" if private else "Workload"} VCN\n{prefix}.0.0/16 (blueprint default)', 20, 50, 1040, 540, parent=comp)
    subnets = []
    tiers = [('app', '1'), ('data', '2'), ('endpoints', '3')] if private else [('web', '0'), ('app', '1'), ('db', '2')]
    for i, (tier, suffix) in enumerate(tiers):
        subnet = d.group('subnet', f'{tier.upper()} subnet\n{prefix}.{suffix}.0/24', 260, 70 + i * 150, 400, 115, parent=vcn)
        public = tier == 'web'
        content = f'Public IPs allowed | web security list\nIngress: TCP {ports} from 0.0.0.0/0' if public else 'Private | shared baseline security list\nNo ingress rules by default'
        if tier == 'endpoints':
            content = 'Private | shared baseline security list\nReady for separately deployed endpoints'
        d.text(content, 15, 65, 365, 40, parent=subnet, size=12)
        subnets.append(subnet)
    private_rt = d.icon('Route Table', 790, 330, parent=vcn, size=48, label='Private route table\nOSN label → SGW' + ('' if private else '\n0.0.0.0/0 → NAT'), label_pos='bottom')
    for i, subnet in enumerate(subnets):
        if not private and i == 0:
            continue
        sy = 260 + 70 + i*150 + 57.5
        d.connect(subnet, private_rt, kind='plain', exit=(1, .5), entry=(0, .5), waypoints=[(1010, sy), (1010, 590)])
    sgw = d.icon('Service Gateway', 1040, 440, parent=vcn, size=52, label='Service Gateway', label_pos='top', border=True)
    d.connect(private_rt, sgw, exit=(1,.5), entry=(0,.5), waypoints=[(1200,590),(1200,700)])
    osn = d.group('osn', 'Oracle Services Network', 1440, 580, 280, 230)
    osn_icon = d.icon('Oracle Services Network', 140, 90, parent=osn, size=58, label='Supported regional services', label_pos='bottom')
    d.text('Service gateway access is distinct\nfrom a service private endpoint.', 15, 160, 250, 45, parent=osn, size=11)
    d.connect(sgw, osn_icon, exit=(1,.5), entry=(0,.5), waypoints=[(1400,700),(1400,670)])
    if not private:
        public_rt = d.icon('Route Table', 130, 127.5, parent=vcn, size=48, label='Public route table\n0.0.0.0/0 → IGW', label_pos='top')
        igw = d.icon('Internet Gateway', 0, 127.5, parent=vcn, size=52, label='Internet Gateway', label_pos='top', border=True)
        d.connect(igw, public_rt, kind='plain', straight=True)
        d.connect(public_rt, subnets[0], kind='plain', exit=(1,.5), entry=(0,.5), straight=True)
        internet = d.group('internet', 'Internet / public edge', 20, 290, 180, 200)
        inet_icon = d.icon('Internet', 90, 90, parent=internet, size=54, label='Web access', label_pos='bottom')
        d.connect(inet_icon, igw, both=True, straight=True)
        nat = d.icon('NAT Gateway', 1040, 250, parent=vcn, size=52, label='NAT Gateway', label_pos='top', border=True)
        d.connect(private_rt, nat, exit=(1,.5), entry=(0,.5), waypoints=[(1200,590),(1200,510)])
        outbound = d.group('internet', 'Internet / outbound only', 1440, 285, 280, 220)
        outbound_icon = d.icon('Internet', 140, 85, parent=outbound, size=54, label='Private subnet egress', label_pos='bottom')
        d.connect(nat, outbound_icon, exit=(1,.5), entry=(0,.5), waypoints=[(1400,510),(1400,370)])
        d.text('Same Internet, shown twice\nfor readability.', 15, 155, 250, 40, parent=outbound, size=11)
    else:
        d.box('PRIVATE DEFAULT\nNo Internet Gateway\nNAT disabled\nNo public ingress', 20, 320, 180, 145, kind='note')
    if index == 3:
        scope = 'OPTIONAL / ZPR\nDisabled by default. Onboarding and policies are tenancy-root operations; onboarding requires the home region.\nWorkload attributes and enforcement require separate configuration and testing.'
    elif private:
        scope = 'OPTIONAL / NAT\nDisabled by default. Enabling NAT creates the gateway only; add the matching route explicitly.\nThis blueprint creates no service-specific private endpoints, NSGs or workloads.'
    elif index == 2:
        scope = 'CUSTOM INPUTS\nThis view shows defaults. CIDRs, subnet maps, routes, security lists and gateway flags are configurable.\nDisabling a gateway requires compatible route changes.'
    else:
        scope = 'WORKLOAD HAND-OFF\nNo compute, load balancer or database is created. App/database ingress is empty.\nTier-to-tier application permissions must be configured separately.'
    d.box(scope, 20, 875, 1700, 95, kind='optional' if index in (2,3,4) else 'note')
    security = 'Baseline egress: VCN CIDR + TCP 443 to regional OSN.' if private else 'All subnet security lists allow outbound traffic by default.'
    d.text(f'{security} Subnet badges denote associated route tables and security lists.\nLines show configured routing / associations, not verified packet flows. Review: 2026-10-28; no new OCI apply or runtime validation.\nSources: blueprint main.tf, variables.tf and the referenced spoke-vcn module. CIDRs are defaults, not a discovered live network.', 20, 995, 1700, 70, size=12)
    return d


def external(title, index):
    d = header(title, index)
    region = d.group('region', 'Existing OCI Region (operator-supplied references; placement must be verified)', 20, 150, 1700, 250)
    for i, (label, icon) in enumerate([('VCNs / vcn_ids', 'VCN (Region Identifier)'), ('Subnets / subnet_ids', 'Route Table and Security List'), ('DRG / drg_id (optional)', 'DRG'), ('Route targets / route_target_ids', None)]):
        group = d.group('other', label, 25+i*420, 55, 385, 165, parent=region)
        if icon:
            # Subnet grouping is the topology symbol; the route/security badge is not a resource claim.
            if i == 1:
                d.text('Existing subnet identifiers\nRoutes and security owned externally', 20, 55, 345, 70, parent=group, size=13)
            else:
                d.icon(icon, 190, 85, parent=group, size=48, label='Externally owned', label_pos='bottom')
        else:
            d.text('Existing target OCIDs\nNo target type inferred', 20, 55, 345, 70, parent=group, size=13)
    d.text('Operator supplies all four input variables. Empty maps and null DRG are the defaults.', 20, 425, 1700, 35, size=13)
    contract = d.group('other', 'This blueprint / local identifier contract only', 20, 495, 1700, 215)
    inputs = d.box('Input OCID references\nvcn_ids | subnet_ids\ndrg_id | route_target_ids', 30, 65, 430, 110, parent=contract)
    normalize = d.box('locals.external_resource_ids\nPrefixes: vcn_, subnet_, route_target_\nAdds drg when non-null', 620, 65, 460, 110, parent=contract)
    outputs = d.box('Outputs\nresource_ids + original input maps\nblueprint_name + name_prefix', 1240, 65, 430, 110, parent=contract)
    d.connect(inputs, normalize, kind='dashed', straight=True)
    d.connect(normalize, outputs, kind='dashed', straight=True)
    downstream = d.box('Downstream deployment / separate operator wiring\nConsumes exported identifiers without adopting the existing resource lifecycle', 520, 790, 900, 100, kind='thirdparty_component')
    d.connect(outputs, downstream, kind='dashed', exit=(.5,1), entry=(.9,0), waypoints=[(1475,750),(1330,750)])
    d.box('OWNERSHIP BOUNDARY\nNo OCI resources or network data-source lookups are declared here. No creation, import, adoption or modification.\nExisting IDs, region, compartment, routes and security must be verified independently.', 20, 930, 1700, 90, kind='note')
    d.text('Dashed arrows represent identifier flow, not network traffic. Source: main.tf, variables.tf and outputs.tf.\nReview: 2026-10-28. No new OCI deployment, inventory verification or packet-flow test.', 20, 1040, 1700, 50, size=12)
    return d


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--render', action='store_true')
    args = parser.parse_args()
    for index, (slug, title, prefix, ports) in enumerate(ITEMS, 1):
        d = external(title, index) if index == 5 else network(slug, title, prefix, ports, index)
        warnings = d.check()
        print(slug, warnings, flush=True)
        if warnings:
            raise RuntimeError('Fix layout warnings before export')
        out = ROOT / 'blueprints/networking' / slug / 'architecture/architecture.drawio'
        d.save(str(out))
        if args.render:
            result = d.render(str(out.with_suffix('.png')), scale=1.5)
            if not result:
                raise RuntimeError('draw.io export did not produce a PNG')
        # Keep generated XML compatible with the repository end-of-file hook.
        with out.open('a') as stream:
            stream.write('\n')


if __name__ == '__main__':
    main()
