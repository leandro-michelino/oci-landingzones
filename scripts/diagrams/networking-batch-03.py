#!/usr/bin/env python3
"""Networking catalog 11-15, with official OCI icons via the installed skill.

The shared network renderer is in networking-batch-02.py. Extension panels
separate conditional resources and control-plane associations from packet paths.
Run with --render for draw.io PNG export. No OCI operations.
"""
import argparse
import importlib.util
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
spec=importlib.util.spec_from_file_location('networking_batch_02',Path(__file__).with_name('networking-batch-02.py'))
base=importlib.util.module_from_spec(spec)
spec.loader.exec_module(base)
ITEMS=[
    ('hub-spoke-with-fortigate-ha','Hub-and-spoke | Optional FortiGate HA','fortigate'),
    ('hub-spoke-with-hub-vcn-bastion-jump-host','Hub-and-spoke | Optional OCI Bastion','bastion'),
    ('hub-spoke-with-transit-routing-nva-ha','Hub-and-spoke | Optional transit NVA HA','nva'),
    ('hub-spoke-with-private-dns-split-horizon','Hub-and-spoke | Private DNS view and zones','dns'),
    ('hub-spoke-with-zpr-micro-segmentation','Hub-and-spoke | Optional ZPR micro-segmentation','zpr'),
]
NOTES={
    'fortigate':'OPTIONAL FORTIGATE: HA instances, floating IPs and instance-principal IAM are all disabled by default.\nTwo node definitions and approved images are required when HA is enabled. Routing and guest HA/SDN configuration are separate; no failover is validated.',
    'bastion':'OPTIONAL BASTION: enable_bastion=false. Targets the hub shared subnet when enabled.\nCreates managed OCI Bastion, not a Compute jump host. Client CIDRs, target reachability and session creation require separate configuration.',
    'nva':'OPTIONAL TRANSIT NVA: Compute and reserved route IPs are disabled; maps are empty by default.\nNo fixed node count, HA control plane, route insertion or guest forwarding is established by this wrapper. Image/subnet/AD inputs are required.',
    'dns':'DEFAULT DNS EXTENSION: Creates a private DNS view, shared.internal / apps.internal zones and hub/app1 resolver associations.\nNo DNS records, public zones, listening/forwarding endpoints or forwarding rules are created by this wrapper. Split-horizon behavior requires query tests.',
    'zpr':'OPTIONAL ZPR: Onboarding and policies are disabled by default; both target tenancy root.\nOnboarding requires the tenancy home region. Workload security attributes and meaningful policy statements require separate configuration and enforcement tests.',
}


def panel(d,kind):
    enabled=kind=='dns'
    box=d.group('other' if enabled else 'optional', 'Extension detail / default DNS resources' if enabled else 'Extension detail / conditional resources, disabled by default', 1760,160,740,1080,style_extra='verticalAlign=top;spacingTop=16;')
    d.text('Detail inset: associations and prerequisites, not a verified traffic path.\nResource placement is stated explicitly below.',20,55,700,45,parent=box,size=12)
    if kind=='fortigate':
        d.text('When enable_fortigate_ha=true: exactly two nodes.\nCompute placement: hub subnets, via interface subnet-key inputs.',20,125,700,55,parent=box,size=13)
        for i,label in enumerate(['FortiGate node A (input)','FortiGate node B (input)']):
            d.box(label+'\nImage / AD / sizing: operator inputs',25+i*355,220,330,100,parent=box,kind='thirdparty_component')
        d.text('Each node: mgmt primary VNIC + untrust / trust / ha_sync attachments.\nDefault mapping: mgmt → mgmt, untrust → dmz, trust → trust, ha_sync → ha.\nPublic IP assignment defaults to false; source/destination checking is skipped.',20,360,700,90,parent=box,size=13)
        d.box('Optional floating private IPs / separate flag\nReserved in a selected hub subnet or assigned to a selected node interface.\nOCI attachment may move outside Terraform (vnic_id changes ignored).',25,500,690,115,parent=box,kind='optional')
        d.box('TENANCY ROOT / optional IAM, separate flag\nDynamic group + policy for instance-principal failover automation.\nPolicy contains tenancy-wide network permissions; requires separate scope review.',25,680,690,130,parent=box,kind='optional')
        d.text('Not supplied by this diagram: image/licensing, guest HA settings,\nhealth probes, SDN behavior or route failover validation.\nNo HA-sync or active/passive traffic line is asserted as operational.',20,870,700,85,parent=box,size=13)
    elif kind=='bastion':
        opt=d.group('optional','Managed service / disabled',25,160,690,220,parent=box,style_extra='verticalAlign=top;spacingTop=12;')
        d.icon('Bastion',90,100,parent=opt,size=60,label='OCI Bastion',label_pos='bottom')
        d.text('Target: hub shared subnet (10.0.2.0/24 default).\nNo Compute instance is created.\nSession TTL default: 3600 seconds.',200,70,460,95,parent=opt,size=14)
        d.box('Client allow list\nEmpty by default. Enabling requires specific approved CIDRs.\n0.0.0.0/0 and ::/0 are rejected.',25,450,690,130,parent=box,kind='note')
        d.box('Sessions / target workloads\nCreated and configured separately. No target VMs or sessions are\ndeclared in this wrapper; target network/security paths must allow access.',25,650,690,130,parent=box,kind='note')
    elif kind=='nva':
        d.text('No appliances or reserved IPs exist under the default inputs.\nThe following are conditional configuration elements, not an installed HA pair.',20,125,700,60,parent=box,size=13)
        opt=d.group('optional','Compute / enable_net_appliance=false',25,230,690,230,parent=box,style_extra='verticalAlign=top;spacingTop=12;')
        d.icon('OCI Compute',90,105,parent=opt,size=56,label='Appliance instances\nfrom input map',label_pos='bottom')
        d.text('Per-entry image, AD and subnet are supplied.\nNo hub-subnet placement is enforced.\nSource/destination checking is skipped.\nAppliance HA and guest forwarding are external.',220,65,440,125,parent=opt,size=13)
        d.box('Route target private IPs / enable_reserved_route_ips=false\nReserved IPs and existing route-target references are separate inputs.\nThe wrapper creates no route-table updates or failover controller.',25,540,690,130,parent=box,kind='optional')
        d.text('The blueprint title describes the intended solution pattern.\nIt does not enforce two nodes, replication, state synchronization,\nhealth checks, traffic insertion or automatic failover.',20,770,700,100,parent=box,size=14)
    elif kind=='dns':
        view=d.icon('DNS',370,200,parent=box,size=64,label='Private DNS view\nenable_private_dns=true',label_pos='top')
        zones=[]
        for i,name in enumerate(['shared.internal','apps.internal']):
            zone=d.box(name+'\nPRIMARY / PRIVATE zone',25+i*355,340,330,100,parent=box)
            zones.append(zone)
            d.connect(view,zone,kind='plain',exit=(.25 if i==0 else .75,1),entry=(.5,0),waypoints=[(1950+355*i,465)])
        resolver=d.box('Existing VCN resolvers / attached_views\nHub + default app1 spoke\nattach_private_view_to_vcn_resolvers=true',25,580,690,130,parent=box)
        d.connect(view,resolver,kind='plain',label='attached_views / view_id',exit=(1,.5),entry=(1,.3),waypoints=[(2485,360),(2485,779)])
        d.text('View association is control-plane configuration, not DNS packet flow.\nThe module discovers resolver IDs from VCN associations.\nRecords, public zones and resolver endpoints are absent here.',20,790,700,100,parent=box,size=13)
    else:
        d.text('TENANCY ROOT / outside the workload compartment boundary',20,140,700,45,parent=box,size=15,bold=True)
        d.box('Onboarding\nenable_zpr_configuration=false\nRequires explicit home_region and region == home_region.',25,240,690,120,parent=box,kind='optional')
        d.box('ZPR policies\nenable_zpr_policies=false\nStarter policy map has empty statements.',25,440,690,120,parent=box,kind='optional')
        d.box('Workload enforcement / separate configuration\nNo security-attribute namespace, attributes or workload assignments\nare declared by this wrapper or its referenced ZPR module.',25,650,690,130,parent=box,kind='note')
        d.text('Network routes and security lists remain a separate control.\nNo East-West authorization or isolation is claimed by this diagram.\nEnablement and actual packet tests require separate approved scope.',20,860,700,100,parent=box,size=14)


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--render',action='store_true')
    args=parser.parse_args()
    for index,(slug,title,kind) in enumerate(ITEMS,11):
        d=base.build(title,'base',index,fortigate=kind=='fortigate',scope_note=NOTES[kind],subtitle=f'NETWORKING {index:02} / Official OCI Toolkit v24.2 / Default foundation + explicit extension scope')
        panel(d,kind)
        warnings=d.check()
        print(slug,warnings,flush=True)
        if warnings:
            raise RuntimeError('Fix all layout warnings before export')
        out=ROOT/'blueprints/networking'/slug/'architecture/architecture.drawio'
        d.save(str(out))
        if args.render and not d.render(str(out.with_suffix('.png')),scale=1.5):
            raise RuntimeError('draw.io PNG export failed')
        with out.open('a') as stream:
            stream.write('\n')


if __name__=='__main__':
    main()
