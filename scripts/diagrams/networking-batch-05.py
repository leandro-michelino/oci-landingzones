#!/usr/bin/env python3
"""Complete Networking diagrams: entries 21-24, including the omitted catalog row.

Uses oci-architecture-diagrams and Oracle's official v24.2 toolkit.
Run with --render to export PNGs. No provisioning or cloud verification.
"""
import argparse
import importlib.util
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
spec=importlib.util.spec_from_file_location('networking_batch_02',Path(__file__).with_name('networking-batch-02.py'))
base=importlib.util.module_from_spec(spec)
spec.loader.exec_module(base)
ITEMS=[
    ('azure-vwan-oci-drg-transit','Azure vWAN + OCI DRG | Transit foundation','vwan'),
    ('regional-prod-nonprod-hubs','Regional production / nonproduction | Separate foundations','separation'),
    ('network-load-balancer','OCI Network Load Balancer | Create or extend','nlb'),
    ('hub-spoke-with-azure-vwan-expressroute','OCI hub-and-spoke + Azure vWAN | ExpressRoute gateway','expressroute'),
]


def header(title,index):
    d=base.Diagram(toolkit=base.TOOLKIT,title=title)
    d.text(title,20,10,2360,45,size=25,bold=True)
    d.text(f'NETWORKING {index:02} / Official OCI Toolkit v24.2 / Source-defined resources and explicit prerequisites',20,65,2360,30,size=13)
    return d


def footer(d,text,y=1300):
    d.box(text,20,y,2360,120,kind='note')
    d.text('Source defaults and operator inputs, not discovered live inventory. Arrows show configuration / intended routing, not verified traffic.\nReview: 2026-10-28. No new provisioning, provider validation, workload connectivity, isolation or failover test.',20,y+155,2360,65,size=12)


def vwan(title,index):
    d=header(title,index)
    az=d.group('thirdparty','Azure / separate Bicep deployment; location = resource group',20,160,800,1000)
    wan=d.box('Standard Virtual WAN\nBranch-to-branch enabled',30,70,740,95,parent=az,kind='thirdparty_component')
    hub=d.box('Virtual Hub 10.89.255.0/24\nHub route table: oci-transit label; explicit routes empty',30,220,740,110,parent=az,kind='thirdparty_component')
    net=d.box('VNet 10.88.0.0/16 / workload subnet 10.88.10.0/24\nvHub VNet connection associated with hub route table\nWorkload UDR default → Internet; NSG TCP 80/443 inbound',30,400,740,140,parent=az,kind='thirdparty_component')
    vpn=d.box('Conditional VNet VPN Gateway (not a vHub VPN Gateway)\nGatewaySubnet 10.88.250.0/27; Standard static public IP\nVpnGw1AZ + Local Network Gateway + IPSec/BGP connection',30,640,740,140,parent=az,kind='thirdparty_component')
    d.connect(wan,hub,kind='plain',straight=True)
    d.connect(hub,net,kind='plain',straight=True)
    d.text('No ExpressRoute gateway or circuit is declared by this Bicep file.\nPeer addresses and secret values must replace the template placeholders.',30,850,740,75,parent=az,size=13)
    reg=d.group('region','OCI / operator-selected region',960,160,1220,1000)
    comp=d.group('compartment','Target compartment / operator input',20,50,1180,920,parent=reg)
    vc=d.group('vcn','Primary VCN\n10.58.0.0/16',80,100,1020,660,parent=comp)
    drg=d.icon('DRG',0,140,parent=vc,size=56,label='DRG / create or existing ID\nVCN attachment',label_pos='top',border=True)
    sn=d.group('subnet','Hub subnet\n10.58.10.0/24',220,160,520,220,parent=vc)
    d.text('Public IPs allowed; TCP 443 ingress from 10.0.0.0/8.\nAll egress; no Compute workloads are declared.',20,90,480,70,parent=sn,size=13)
    rt=d.icon('Route Table',850,300,parent=vc,size=52,label='RT: default → IGW\nAzure CIDRs → DRG (always)',label_pos='bottom')
    igw=d.icon('Internet Gateway',1020,470,parent=vc,size=52,label='IGW',label_pos='top',border=True)
    d.connect(sn,rt,kind='plain',exit=(1,.5),entry=(0,.5),straight=True)
    d.connect(rt,drg,exit=(.5,0),entry=(1,.5),waypoints=[(1910,430),(1110,430),(1110,450)])
    d.connect(rt,igw,exit=(1,.5),entry=(0,.5),waypoints=[(2020,610),(2020,780)])
    inet=d.group('internet','Internet',2240,700,200,180)
    ic=d.icon('Internet',100,85,parent=inet,size=48,label='Default egress',label_pos='bottom')
    d.connect(igw,ic,straight=True)
    d.connect(vpn,drg,kind='vpn',label='OCI CPE + IPSec / requested; IP TBC',exit=(1,.5),entry=(0,.5),waypoints=[(900,870),(900,450)])
    d.icon('Notifications',960,830,parent=comp,size=48,label='Alert topic enabled by default\nNo alarms or subscriptions declared',label_pos='top')
    d.text('VPN flag defaults true; Azure CPE IP is null → incomplete full-default inputs.\nNo NAT / SGW. Network creation can be disabled; DRG can be reused.',60,815,780,65,parent=comp,size=12)
    footer(d,'CONTRACT LIMITS / metadata is not enforcement\nDefault mode: without-interconnect. Interconnect mode needs existing FastConnect, ExpressRoute, vWAN and vHub IDs.\nSegmentation maps, BGP timers, DNS and 120-second convergence target are contracts; they do not deploy segmentation or a failover controller.\nThe Azure VPN endpoint is in the workload VNet; the template does not declare a vHub VPN gateway. Validate actual transit and static OCI IPSec routes separately.')
    return d


def separation(title,index):
    d=header(title,index)
    region=d.group('region','One OCI region / operator input',20,160,2360,900)
    comp=d.group('compartment','Same target compartment / distinct network foundations',20,50,2320,820,parent=region)
    for k,(name,hp,sp,key) in enumerate([('Production','10.40','10.41','prodapp'),('Nonproduction','10.50','10.51','nonprodapp')]):
        area=d.group('other',name+' / module.'+('prod_network' if k==0 else 'nonprod_network'),20+k*1160,60,1120,720,parent=comp)
        drg=d.icon('DRG',560,80,parent=area,size=48,label=name+' DRG',label_pos='top')
        hub=d.group('vcn',f'{name} hub\n{hp}.0.0/16',40,170,450,460,parent=area)
        spoke=d.group('vcn',f'{key} spoke\n{sp}.0.0/16',630,170,450,460,parent=area)
        ax,ay=area.abs
        d.connect(drg,hub,kind='plain',exit=(0,.5),entry=(.5,0),waypoints=[(ax+265,ay+80)])
        d.connect(drg,spoke,kind='plain',exit=(1,.5),entry=(.5,0),waypoints=[(ax+855,ay+80)])
        for group,prefix,names in [(hub,hp,['DMZ','FIREWALL','SHARED']),(spoke,sp,['WEB','APP','DB'])]:
            for j,n in enumerate(names):
                subnet=d.group('subnet',f'{n}\n{prefix}.{j}.0/24',100,65+j*120,320,100,parent=group)
                d.text('Public IPs allowed' if group is hub and j==0 else 'Private',15,55,290,30,parent=subnet,size=12)
        for icon,y,label in [('Internet Gateway',120,'IGW'),('NAT Gateway',250,'NAT'),('Service Gateway',380,'SGW')]:
            d.icon(icon,0,y,parent=hub,size=42,label=label,label_pos='left',border=True)
        d.icon('Service Gateway',0,380,parent=spoke,size=42,label='SGW',label_pos='left',border=True)
        d.text('Hub: public RT → IGW; private RT → NAT / SGW. Spoke: default → own DRG; OSN → SGW.\nBaseline lists: empty ingress, all egress. No connection between these foundations is declared.',20,655,1080,45,parent=area,size=11)
    footer(d,'ISOLATION SCOPE\nDistinct hub/spoke CIDRs, names, tags, DRGs and attachments in the same region and compartment. Two NAT gateways in total.\nNo cross-foundation peering, firewall insertion, workload policy or isolation packet test is provided by this documentation.\nThe diagram shows network separation, not a confirmed security outcome.',1140)
    return d


def nlb(title,index):
    d=header(title,index)
    region=d.group('region','OCI / region input',20,160,1680,850)
    comp=d.group('compartment','Target compartment / operator input',20,50,1640,770,parent=region)
    vc=d.group('vcn','Existing VCN / supplied separately\nCIDR TBC; no VCN created by this blueprint',30,100,1580,560,parent=comp)
    subnet=d.group('subnet','Existing subnet / subnet_id input\nCIDR TBC',30,100,680,350,parent=vc)
    opt=d.group('optional','Conditional create / or reuse existing NLB',25,70,630,240,parent=subnet,style_extra='verticalAlign=top;spacingTop=12;')
    service=d.box('Network Load Balancer (Layer 4)\nCreate flag=false; existing ID=null by default\nWhen created: private=true; IP version IPV4\nSource/destination preservation=false; symmetric hash=false',25,65,580,135,parent=opt)
    config=d.box('Listeners and backend sets\nBoth maps empty by default\nPolicy / health checker / protocol / ports from inputs',850,110,650,150,parent=vc)
    d.connect(service,config,kind='dashed',exit=(1,.5),entry=(0,.5),waypoints=[(825,540),(825,545)])
    d.text('The existing network, subnet routes and security controls are supplied separately.\nThis blueprint configures the NLB and optional access policy; it does not create workload targets.',50,700,1450,45,parent=comp,size=12)
    targets=d.group('other','Backend targets / operator-supplied ownership and placement',1760,160,700,470)
    d.box('Configured IP addresses or target IDs\nNo backend VMs are created.\nTargets need not be in the NLB subnet.\nHealth, network reachability and security remain to be verified.',25,100,650,180,parent=targets)
    d.connect(config,targets,kind='dashed',exit=(1,.5),entry=(0,.5),waypoints=[(1730,545),(1730,395)])
    iam=d.group('optional','IAM / no policy by default',1760,720,700,290,style_extra='verticalAlign=top;spacingTop=12;')
    d.text('policy_statements=[]\nWhen provided, IAM policy targets tenancy root by default\nor an explicit policy compartment, through the home-region provider.\nThis scope is separate from the network compartment.',25,75,650,140,parent=iam,size=14)
    footer(d,'DEFAULT RESULT / NO RESOURCE CREATION\ncreate_network_load_balancer=false, existing NLB ID=null, backend_sets={}, listeners={}, policy_statements=[].\nTo create, supply a subnet and enable creation. To extend, supply an existing NLB ID and the desired configuration maps.\nDashed arrows show configuration relationships; there is no operational listener or backend path under the defaults.',1090)
    return d


def expressroute(title,index):
    note='DEFAULT OCI FOUNDATION ONLY: FastConnect, IPSec and route-contract validation are disabled.\nThe separate Azure template creates one VNet by default; existing ExpressRoute private-peering identifiers are required to attach a circuit.'
    d=base.build(title,'base',index,scope_note=note,subtitle=f'NETWORKING {index:02} / Official OCI Toolkit v24.2 / Source foundation + separate Azure template')
    az=d.group('thirdparty','Azure / separate Bicep template, resource-group location',1760,160,740,1080)
    wan=d.box('Standard Virtual WAN + Virtual Hub\nvHub prefix 10.88.255.0/24 (default)\nHub route table: oci-transit label; routes empty',25,80,690,130,parent=az,kind='thirdparty_component')
    er=d.box('ExpressRoute Gateway / deploy flag=true\nConnection created only if private-peering ID is nonempty\nCircuit itself is not created',25,300,690,130,parent=az,kind='thirdparty_component')
    net=d.box('Default Azure VNet app1 / 10.88.10.0/24\nWorkload subnet 10.88.10.0/24 + NSG\nvHub VNet connection associated with route table',25,530,690,130,parent=az,kind='thirdparty_component')
    d.connect(wan,er,kind='plain',straight=True)
    d.connect(wan,net,kind='plain',exit=(1,.5),entry=(1,.5),waypoints=[(2485,305),(2485,755)])
    d.text('NSG allows all protocols/ports from default OCI prefixes\n10.0.0.0/16 and 10.1.0.0/16. Review customer access intent.\nAdditional VNets / OCI spokes require additional map entries.',25,730,690,90,parent=az,size=13)
    d.box('Connectivity contract / metadata only\nAzure VNet-to-OCI-spoke mappings do not create peering.\nExpressRoute peering/circuit IDs default null; validation flag=false.\nThe Azure template declares no backup VPN gateway.',25,890,690,145,parent=az,kind='note')
    return d


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--render',action='store_true')
    args=parser.parse_args()
    for index,(slug,title,kind) in enumerate(ITEMS,21):
        d={'vwan':vwan,'separation':separation,'nlb':nlb,'expressroute':expressroute}[kind](title,index)
        warnings=d.check()
        print(slug,warnings,flush=True)
        if warnings:
            raise RuntimeError('Fix all layout warnings before export')
        out=ROOT/'blueprints/networking'/slug/'architecture/architecture.drawio'
        d.save(str(out))
        if args.render and not d.render(str(out.with_suffix('.png')),scale=1.5):
            raise RuntimeError('draw.io export failed')
        with out.open('a') as stream:
            stream.write('\n')


if __name__=='__main__':
    main()
