#!/usr/bin/env python3
"""Draw Networking catalog entries 6-10 using oci-architecture-diagrams.

Requires the installed skill and Oracle's official v24.2 toolkit.
Run with --render for PNG export through draw.io Desktop. No OCI operations.
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
    ('hub-spoke-with-drg-and-three-tier-vcns', 'Hub-and-spoke | DRG and three-tier VCNs', 'base'),
    ('hub-spoke-with-hub-vcn-ipsec-vpn', 'Hub-and-spoke | Optional IPSec VPN', 'vpn'),
    ('hub-spoke-with-hub-vcn-fastconnect-vc', 'Hub-and-spoke | Optional FastConnect', 'fc'),
    ('hub-spoke-with-hub-vcn-net-firewall', 'Hub-and-spoke | Optional Network Firewall', 'fw'),
    ('hub-spoke-with-hub-vcn-net-appliance', 'Hub-and-spoke | Optional network appliance', 'nva'),
]


def build(title, variant, index):
    d = Diagram(toolkit=TOOLKIT, title=title)
    d.text(title, 20, 10, 1960, 45, size=25, bold=True)
    d.text(f'NETWORKING {index:02} / Official OCI Toolkit v24.2 / Default network foundation + explicitly marked optional extension', 20, 65, 1960, 25, size=13)
    region = d.group('region', 'OCI Region (operator-selected; deployment value not specified)', 300, 160, 1400, 880)
    comp = d.group('compartment', 'Target compartment (operator input)', 20, 50, 1360, 810, parent=region)
    drg = d.icon('DRG', 680, 90, parent=comp, size=58, label='DRG / VCN attachments', label_pos='top')
    hub = d.group('vcn', 'Hub VCN\n10.0.0.0/16 (default)', 30, 190, 570, 540, parent=comp)
    spoke = d.group('vcn', 'Spoke app1 VCN\n10.1.0.0/16 (one default spoke)', 750, 190, 570, 540, parent=comp)
    d.connect(drg, hub, kind='plain', label='Hub attachment', exit=(.35,1), entry=(.5,0), waypoints=[(990,345),(635,345)])
    d.connect(drg, spoke, kind='plain', label='Spoke attachment', exit=(.65,1), entry=(.5,0), waypoints=[(1010,330),(1355,330)])
    hub_subnets = []
    for i, (name, suffix, y, h) in enumerate([('DMZ','0',60,115),('FIREWALL','1',210,170),('SHARED','2',405,110)]):
        sn = d.group('subnet', f'{name} subnet\n10.0.{suffix}.0/24', 160, y, 350, h, parent=hub)
        hub_subnets.append(sn)
        if name == 'FIREWALL' and variant == 'fw':
            opt = d.group('optional', 'Optional extension / disabled', 15, 55, 320, 100, parent=sn, style_extra='verticalAlign=top;spacingTop=8;')
            d.icon('Firewall', 40, 60, parent=opt, size=36, label='Network Firewall\nenable_network_firewall=false', label_pos='right')
        else:
            d.text('Public IPs allowed; no ingress rules' if name=='DMZ' else 'Private; no ingress rules', 15, 65, 320, 35, parent=sn, size=12)
    hub_public_rt = d.icon('Route Table', 65, 117.5, parent=hub, size=44, label='Public RT\n0.0.0.0/0 → IGW', label_pos='top')
    hub_private_rt = d.icon('Route Table', 65, 365, parent=hub, size=44, label='Private RT\n0.0.0.0/0 → NAT\nOSN label → SGW', label_pos='top')
    igw = d.icon('Internet Gateway', 0, 117.5, parent=hub, size=48, label='IGW', label_pos='top', border=True)
    nat = d.icon('NAT Gateway', 0, 290, parent=hub, size=48, label='NAT', label_pos='top', border=True)
    hub_sgw = d.icon('Service Gateway', 100, 540, parent=hub, size=48, label='Hub SGW', label_pos='right', border=True)
    d.connect(hub_public_rt, igw, straight=True)
    d.connect(hub_subnets[0], hub_public_rt, kind='plain', straight=True)
    d.connect(hub_subnets[1], hub_private_rt, kind='plain', exit=(0,.65), entry=(1,.5), waypoints=[(470,720),(470,765)])
    d.connect(hub_subnets[2], hub_private_rt, kind='plain', exit=(0,.5), entry=(1,.5), waypoints=[(470,860),(470,765)])
    d.connect(hub_private_rt, nat, exit=(0,.5), entry=(1,.5), waypoints=[(390,765),(390,690)])
    d.connect(hub_private_rt, hub_sgw, exit=(.5,1), entry=(.5,0), waypoints=[(415,915),(450,915)])
    internet = d.group('internet', 'Internet / hub DMZ route', 20, 405, 200, 185)
    inet = d.icon('Internet', 100, 80, parent=internet, size=48, label='No ingress rules\nby default', label_pos='bottom')
    d.connect(igw, inet, exit=(0,.5), entry=(1,.5), straight=True)
    outbound = d.group('internet', 'Internet / hub egress only', 20, 630, 200, 185)
    out = d.icon('Internet', 100, 80, parent=outbound, size=48, label='Same Internet\nshown twice', label_pos='bottom')
    d.connect(nat, out, exit=(0,.5), entry=(1,.5), straight=True)
    spoke_subnets = []
    for i, name in enumerate(['WEB','APP','DB']):
        sn = d.group('subnet', f'{name} subnet\n10.1.{i}.0/24', 30, 65+i*155, 330, 115, parent=spoke)
        d.text('Private; no ingress rules\nShared baseline security list', 15, 65, 300, 40, parent=sn, size=12)
        spoke_subnets.append(sn)
    spoke_rt = d.icon('Route Table', 460, 285, parent=spoke, size=44, label='Private RT\n0.0.0.0/0 → DRG\nOSN label → SGW', label_pos='bottom')
    spoke_sgw = d.icon('Service Gateway', 285, 540, parent=spoke, size=48, label='Spoke SGW', label_pos='right', border=True)
    for i, sn in enumerate(spoke_subnets):
        y=400+65+i*155+57.5
        d.connect(sn, spoke_rt, kind='plain', exit=(1,.5), entry=(0,.5), waypoints=[(1470,y),(1470,685)])
    d.connect(spoke_rt, drg, exit=(.5,0), entry=(.5,1), waypoints=[(1530,365),(1000,365)], label='Default route to DRG')
    d.connect(spoke_rt, spoke_sgw, exit=(1,.5), entry=(.5,0), waypoints=[(1610,685),(1610,910),(1355,910)])
    osn = d.group('osn', 'Oracle Services Network / supported regional services', 500, 1110, 1100, 150)
    osn_icon = d.icon('Oracle Services Network', 550, 75, parent=osn, size=48, label='', label_pos='bottom')
    d.text('Direct SGW paths from hub and spoke.\nService gateway access is distinct from service private endpoints.', 20, 105, 1060, 35, parent=osn, size=12)
    d.connect(hub_sgw, osn_icon, exit=(.5,1), entry=(0,.5), waypoints=[(450,1185)])
    d.connect(spoke_sgw, osn_icon, exit=(.5,1), entry=(1,.5), waypoints=[(1355,1070),(1150,1070),(1150,1185)])
    if variant in ('vpn','fc'):
        remote = d.group('onprem', 'On-premises / optional link', 20, 145, 200, 210)
        cpe = d.icon('Customer Premises Equipment', 100, 85, parent=remote, size=48, label='CPE IP / CIDRs TBC' if variant=='vpn' else 'Partner / BGP details TBC', label_pos='bottom')
        d.text('Disabled by default', 15, 160, 170, 25, parent=remote, size=12)
        d.connect(cpe, drg, kind='vpn' if variant=='vpn' else 'fastconnect', label='Optional IPSec / off by default' if variant=='vpn' else 'Optional FastConnect / off by default', waypoints=[(260,230),(260,300)], entry=(0,.5))
    notes = {
        'base': 'FOUNDATION ONLY: Hub + one private three-tier spoke + DRG attachments. More spokes require input map entries.\nAttachments do not establish inspected transit, centralized NAT, hub ingress routes or workload connectivity.',
        'vpn': 'OPTIONAL VPN: enable_ipsec=false. When enabled, creates OCI CPE + IPSec resources bound to the DRG.\nReal CPE public/private IP and on-premises routes are required. No remote-device setup or verified tunnel / BGP / failover is implied.',
        'fc': 'OPTIONAL FASTCONNECT: enable_fastconnect=false. Default circuit type PRIVATE; default bandwidth 1 Gbps.\nCarrier/partner, customer ASN and provisioning inputs are required. Circuit and partner costs need separate review; no active circuit is shown.',
        'fw': 'OPTIONAL FIREWALL: enable_network_firewall=false. When enabled, targets the hub firewall subnet.\nAn existing policy may be supplied or a policy created. Traffic insertion, rules and symmetric routing require separate configuration and testing.',
        'nva': 'OPTIONAL APPLIANCES: enable_net_appliance=false; enable_reserved_route_ips=false; appliance/route-IP maps are empty.\nImage, availability domain, subnet and route-target inputs are required. The blueprint does not force hub placement or establish HA / guest forwarding.',
    }
    d.box(notes[variant], 20, 1300, 1680, 95, kind='note' if variant=='base' else 'optional')
    d.text('All CIDRs shown are blueprint defaults, not discovered live networks. Subnet badges denote route-table / security-list associations.\nSolid arrows show configured routes or an explicitly optional link; plain lines show associations / attachments. Baseline ingress is empty; egress allows all.\nReview: 2026-10-28 against blueprint/module sources. No new OCI provisioning, provider validation, packet-flow or failover test.', 20, 1420, 1680, 70, size=12)
    return d


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--render',action='store_true')
    args=parser.parse_args()
    for index,(slug,title,variant) in enumerate(ITEMS,6):
        d=build(title,variant,index)
        warnings=d.check()
        print(slug,warnings,flush=True)
        if warnings:
            raise RuntimeError('Fix all layout warnings before export')
        out=ROOT/'blueprints/networking'/slug/'architecture/architecture.drawio'
        d.save(str(out))
        if args.render and not d.render(str(out.with_suffix('.png')),scale=1.5):
            raise RuntimeError('draw.io PNG export failed')
        # Keep generated XML compatible with the repository end-of-file hook.
        with out.open('a') as stream:
            stream.write('\n')


if __name__=='__main__':
    main()
