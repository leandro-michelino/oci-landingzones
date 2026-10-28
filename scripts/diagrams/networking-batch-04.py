#!/usr/bin/env python3
"""Draw Networking catalog 16-20 with the installed OCI diagram skill.

Requires the official Oracle v24.2 toolkit. Cross-cloud resources are labelled
third-party boxes; links and input contracts are distinguished from live paths.
Run with --render for draw.io PNG export. No cloud operations.
"""
import argparse
import importlib.util
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
spec=importlib.util.spec_from_file_location('networking_batch_02',Path(__file__).with_name('networking-batch-02.py'))
base=importlib.util.module_from_spec(spec)
spec.loader.exec_module(base)
ITEMS=[
    ('hub-spoke-with-dual-region-dr','Dual-region hub-and-spoke | Independent foundations','dr'),
    ('multi-tenancy-shared-services','Shared services | Single-tenancy network and DNS','tenancy'),
    ('hub-spoke-with-multicloud-interconnect','Hub-and-spoke | Optional multicloud links','multi'),
    ('aws-oci-hybrid-network-backbone','AWS + OCI | Hybrid network backbone','aws'),
    ('azure-oci-dual-connectivity','Azure + OCI | Dual connectivity contract','azure'),
]


def header(title,index):
    d=base.Diagram(toolkit=base.TOOLKIT,title=title)
    d.text(title,20,10,2350,45,size=25,bold=True)
    d.text(f'NETWORKING {index:02} / Official OCI Toolkit v24.2 / Source defaults and explicit prerequisites / No live deployment',20,65,2350,30,size=13)
    return d


def regional(d,x,label):
    region=d.group('region',label,x,170,1100,790)
    comp=d.group('compartment','Compartment input / each region',20,50,1060,720,parent=region)
    drg=d.icon('DRG',530,80,parent=comp,size=48,label='Regional DRG',label_pos='top')
    hub=d.group('vcn','Hub VCN\n10.0.0.0/16',40,170,420,470,parent=comp)
    spoke=d.group('vcn','Spoke app1 VCN\n10.1.0.0/16',600,170,420,470,parent=comp)
    d.connect(drg,hub,kind='plain',exit=(0,.5),entry=(.5,0),waypoints=[(x+270,300)])
    d.connect(drg,spoke,kind='plain',exit=(1,.5),entry=(.5,0),waypoints=[(x+830,300)])
    for vcn,prefix,names in [(hub,'10.0',['DMZ','FIREWALL','SHARED']),(spoke,'10.1',['WEB','APP','DB'])]:
        for i,name in enumerate(names):
            sn=d.group('subnet',f'{name}\n{prefix}.{i}.0/24',100,65+i*120,290,100,parent=vcn)
            d.text('Public IPs allowed' if vcn is hub and i==0 else 'Private',15,55,260,30,parent=sn,size=12)
    for name,y in [('Internet Gateway',120),('NAT Gateway',250),('Service Gateway',380)]:
        d.icon(name,0,y,parent=hub,size=42,label={'Internet Gateway':'IGW','NAT Gateway':'NAT','Service Gateway':'SGW'}[name],label_pos='left',border=True)
    d.icon('Service Gateway',0,380,parent=spoke,size=42,label='SGW',label_pos='left',border=True)
    d.text('Hub: public RT → IGW; private RT → NAT / SGW. Spoke: default route → DRG; OSN route → SGW.\nShared baseline lists: no ingress; all egress. Gateways shown on VCN edges; no workload resources.',20,660,1020,45,parent=comp,size=11)


def dual(title,index):
    d=header(title,index)
    regional(d,20,'Primary region / required operator input')
    regional(d,1200,'Secondary region / eu-amsterdam-1 default')
    d.box('NO INTER-REGION LINK IS DECLARED\nTwo separate hub/spoke foundations and regional DRGs. No RPC, replication, application failover or DR orchestration is created.',20,1020,2280,110,kind='note')
    d.box('ADDRESSING / DEFAULTS\nBoth module calls inherit the same hub 10.0.0.0/16 and spoke 10.1.0.0/16 CIDRs. Do not infer routable inter-region connectivity.\nThe wrapper does not expose network CIDR overrides; connected designs require a reviewed addressing/configuration change.',20,1180,2280,110,kind='note')
    d.text('CIDRs and secondary region are source defaults, not live inventory. Primary and secondary compartment values are supplied / inherited.\nSolid-free attachment lines are topology associations only. Routing descriptions do not prove packet flow. Review: 2026-10-28; no new OCI validation.',20,1330,2280,65,size=12)
    return d


def shared(title,index,kind):
    note=('DEFAULT SHARED DNS: one private view, shared.internal zone, hub + app1 resolver associations.\nThis wrapper creates no second tenancy, cross-tenancy IAM, cross-tenancy peering or consumer onboarding.' if kind=='tenancy' else 'OPTIONAL LINKS: enable_fastconnect=false and enable_ipsec=false. Both conditional OCI services attach to the shared DRG when enabled.\nThe remote cloud, carrier circuit, routes, symmetric return paths and failover policy require separate configuration.')
    d=base.build(title,'base',index,scope_note=note,subtitle=f'NETWORKING {index:02} / Official OCI Toolkit v24.2 / Default foundation + explicit extension scope')
    panel=d.group('other' if kind=='tenancy' else 'optional','Shared-services detail / source scope' if kind=='tenancy' else 'Multicloud detail / conditional links, disabled by default',1760,160,740,1080,style_extra='verticalAlign=top;spacingTop=16;')
    d.text('Detail inset: configuration and ownership, not a verified packet path.',20,60,700,40,parent=panel,size=12)
    if kind=='tenancy':
        view=d.icon('DNS',370,200,parent=panel,size=60,label='Private DNS view\nenable_private_dns=true',label_pos='top')
        zone=d.box('shared.internal\nPRIMARY / PRIVATE zone (default)',25,350,690,110,parent=panel)
        resolver=d.box('Hub + app1 VCN resolvers\nPrivate view attached by this wrapper',25,570,690,110,parent=panel)
        d.connect(view,zone,kind='plain',straight=True)
        d.connect(zone,resolver,kind='dashed',straight=True)
        d.box('Other tenancies / separately designed\nNo resources, authorization policy or network link for a second tenancy\nare declared by main.tf. The title describes an intended pattern.',25,780,690,150,parent=panel,kind='thirdparty_component')
    else:
        drg=d.icon('DRG',570,200,parent=panel,size=54,label='Same foundation DRG\n(detail reference)',label_pos='top')
        fc=d.box('Remote cloud / carrier\nPartner + ASN inputs TBC',25,340,330,110,parent=panel,kind='thirdparty_component')
        vpn=d.box('Remote VPN gateway\nCPE IP + remote CIDRs TBC',25,620,330,110,parent=panel,kind='thirdparty_component')
        d.connect(fc,drg,kind='fastconnect',label='Optional FastConnect / off',exit=(1,.5),entry=(0,.5),waypoints=[(2210,555),(2210,360)])
        d.connect(vpn,drg,kind='vpn',label='Optional IPSec / off',exit=(1,.5),entry=(.5,1),waypoints=[(2330,835)])
        d.text('FastConnect creates an OCI virtual circuit only when enabled.\nIPSec creates OCI CPE + IPSec resources when enabled.\nRemote-cloud resources and active circuit hand-off are external.\nNo automated link preference or failover is configured here.',20,850,700,130,parent=panel,size=13)
    return d


def crosscloud(title,index,cloud):
    aws=cloud=='aws'
    remote_cidr='10.94.0.0/16' if aws else '10.88.0.0/16'
    oci_cidr='10.54.0.0/16' if aws else '10.58.0.0/16'
    subnet_cidr='10.54.10.0/24' if aws else '10.58.10.0/24'
    remote_subnet='10.94.10.0/24' if aws else '10.88.10.0/24'
    d=header(title,index)
    remote=d.group('thirdparty',('AWS / separate CloudFormation deployment' if aws else 'Azure / separate Bicep deployment'),20,160,680,850)
    d.box(('VPC' if aws else 'VNet')+f' {remote_cidr}\nWorkload subnet {remote_subnet}\n'+('No auto public IPs; RT default → Internet Gateway' if aws else 'Workload UDR default → Internet; NSG allows TCP 80/443 inbound'),30,70,620,190,parent=remote,kind='thirdparty_component')
    d.box('VPC Flow Logs → CloudWatch Logs\nKMS key + IAM delivery role; 30-day log retention' if aws else 'GatewaySubnet 10.88.250.0/27 (when VPN enabled)\nStandard static Public IP; VPN gateway VpnGw1AZ',30,300,620,120,parent=remote,kind='thirdparty_component')
    gateway=d.box('Transit Gateway + VPC attachment\nConditional Customer Gateway + static-route VPN' if aws else 'VPN Gateway + Local Network Gateway\nIPSec connection with BGP enabled (conditional)',30,480,620,120,parent=remote,kind='thirdparty_component')
    d.box('No Direct Connect is created by this template.\nTGW/VPN routing still needs end-to-end agreement.' if aws else 'No ExpressRoute circuit is created by this template.\nGateway IP / peer IP / shared secret inputs need real values.',30,680,620,120,parent=remote,kind='note')
    region=d.group('region','OCI / operator-selected region, OCI-primary deployment',850,160,1200,850)
    comp=d.group('compartment','Target compartment / operator input',20,50,1160,780,parent=region)
    vcn=d.group('vcn',('Backbone' if aws else 'Primary')+f' VCN\n{oci_cidr} (default)',80,130,980,570,parent=comp)
    drg=d.icon('DRG',0,130,parent=vcn,size=56,label='DRG + VCN attachment\nCreated by default / existing ID supported',label_pos='top',border=True)
    sn=d.group('subnet',f'Backbone subnet\n{subnet_cidr}',220,130,500,210,parent=vcn)
    d.text('Public IPs allowed on VNICs.\nSecurity list: TCP 443 ingress from 10.0.0.0/8; all egress.\nNo compute or load balancer is created.',20,85,460,95,parent=sn,size=13)
    rt=d.icon('Route Table',820,240,parent=vcn,size=50,label='Default RT\n0.0.0.0/0 → IGW\nRemote CIDR → DRG if VPN enabled',label_pos='bottom')
    igw=d.icon('Internet Gateway',980,350,parent=vcn,size=52,label='IGW',label_pos='top',border=True)
    d.connect(sn,rt,kind='plain',exit=(1,.5),entry=(0,.5),straight=True)
    d.connect(rt,igw,exit=(1,.5),entry=(0,.5),waypoints=[(1840,580),(1840,690)])
    d.connect(rt,drg,label='Remote prefix / conditional on VPN flag',exit=(.5,0),entry=(.5,0),waypoints=[(1770,405),(950,405)])
    d.connect(gateway,drg,kind='vpn',label='VPN requested by default / CPE IP TBC',exit=(1,.5),entry=(0,.5),waypoints=[(780,700),(780,470)])
    internet=d.group('internet','Internet',2110,510,250,190)
    inet=d.icon('Internet',125,90,parent=internet,size=56,label='OCI subnet default route',label_pos='bottom')
    d.connect(igw,inet,exit=(1,.5),entry=(0,.5),waypoints=[(2090,690),(2090,600)])
    d.icon('Notifications',1030,720,parent=comp,size=48,label='Alert topic / default enabled\nNo subscription or alarm declared',label_pos='top')
    d.text('Create-network=true and attach-VCN-to-DRG=true by default.\nNo NAT or Service Gateway is declared in this OCI root.\nAn existing VCN/DRG can be supplied using the documented flags.',100,715,720,55,parent=comp,size=12)
    d.box('INTERCONNECT CONTRACT / separate provisioning\nconnectivity_mode=without-interconnect by default; circuit IDs are null.\nInterconnect mode requires existing FastConnect + '+('Direct Connect' if aws else 'ExpressRoute')+' identifiers; it creates neither circuit.',20,1070,1000,150,kind='optional')
    d.box('DEFAULT INPUTS ARE INCOMPLETE\nVPN flag defaults true but remote CPE public IP is null: full-default plan cannot pass that prerequisite.\nTemplate placeholder addresses and secrets must be replaced; no tunnel interoperability is proven.',1080,1070,1280,150,kind='note')
    if not aws:
        d.box('AZURE CONTRACTS / metadata, not deployed DNS or failover\nBGP ASN/timers, path weights, corp.internal DNS and the 120-second failover target are input/runbook data.\nThe OCI root declares static IPSec routes; it does not configure tunnel BGP settings or a failover controller.',20,1270,2340,130,kind='note')
    else:
        d.box('AWS / OCI ROUTING LIMIT\nThe two cloud templates are separate deployments, not an automatically paired VPN.\nPeer addressing, tunnel parameters, route exchange and cloud-specific routing must be reconciled before packet tests.',20,1270,2340,130,kind='note')
    d.text('Defaults are source examples, not live inventory or approved costs. External-cloud resources use labelled third-party boxes, not OCI stand-in icons.\nSolid arrows are requested/configured route or VPN intent, not verified traffic. Detail scope: root Terraform + separate CloudFormation/Bicep template.\nReview: 2026-10-28. No provisioning, new provider validation, packet-flow, BGP or failover test.',20,1440,2340,75,size=12)
    return d


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--render',action='store_true')
    args=parser.parse_args()
    for index,(slug,title,kind) in enumerate(ITEMS,16):
        d=dual(title,index) if kind=='dr' else shared(title,index,kind) if kind in ('tenancy','multi') else crosscloud(title,index,kind)
        warnings=d.check()
        print(slug,warnings,flush=True)
        if warnings:
            raise RuntimeError('Fix every layout warning before export')
        out=ROOT/'blueprints/networking'/slug/'architecture/architecture.drawio'
        d.save(str(out))
        if args.render and not d.render(str(out.with_suffix('.png')),scale=1.5):
            raise RuntimeError('draw.io PNG export failed')
        with out.open('a') as stream:
            stream.write('\n')


if __name__=='__main__':
    main()
