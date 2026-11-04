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
icon_spec=importlib.util.spec_from_file_location('cloud_icons',Path(__file__).with_name('cloud-icons.py'))
cloud=importlib.util.module_from_spec(icon_spec); icon_spec.loader.exec_module(cloud)
ITEMS=[
    ('azure-vwan-oci-drg-transit','Azure vWAN + OCI DRG | ExpressRoute + FastConnect primary','vwan'),
    ('regional-prod-nonprod-hubs','Regional production / nonproduction | Separate foundations','separation'),
    ('network-load-balancer','OCI Network Load Balancer | Create or extend','nlb'),
    ('hub-spoke-with-azure-vwan-expressroute','OCI hub-and-spoke + Azure vWAN | ExpressRoute gateway','expressroute'),
]


def header(title,index):
    d=base.Diagram(toolkit=base.TOOLKIT,title=title)
    d.text(title,20,10,2360,45,size=25,bold=True)
    d.text(f'NETWORKING {index:02} / Official OCI Toolkit v24.2 / Source-defined resources and explicit prerequisites',20,65,2360,30,size=13)
    return d


def vwan(title,index):
    d=header('Azure vWAN + OCI DRG | ExpressRoute + FastConnect primary',index)
    d.text('Independent transport lines: primary private Interconnect above; optional classic VPN alternative below.',20,108,2500,30,size=16)
    az=d.group('thirdparty','Azure / Virtual WAN foundation / supported Interconnect location',20,170,1100,1050)
    reg=d.group('region','OCI / operator-selected supported region / explicit compartment',1420,170,1100,1050)
    net=d.group('thirdparty','Workload VNet / 10.88.0.0/16 (source default)',40,80,1020,225,parent=az)
    cloud.icon(d,'Microsoft.Network/virtualNetworks',50,50,parent=net,size=45)
    subnet=cloud.box(d,'Microsoft.Network/virtualNetworks/subnets','Workload subnet 10.88.10.0/24\nSource UDR: Internet default / NSG TCP 80 + 443 inbound',30,90,960,100,parent=net,icon_size=60,text_size=18)
    vc=d.group('vcn','OCI primary VCN / 10.58.0.0/16 (source default)',40,80,1020,225,parent=reg)
    sn=d.group('subnet','Hub subnet / 10.58.10.0/24',30,90,650,100,parent=vc)
    rt=d.icon('Route Table',840,140,parent=vc,size=60,label='Remote prefixes → DRG\nSelected transport required',label_pos='top')
    d.connect(sn,rt,kind='plain',straight=True)
    wan=cloud.icon(d,'Microsoft.Network/virtualWans',130,470,parent=az,size=80,label='Standard Virtual WAN',label_pos='top')
    hub=cloud.icon(d,'Microsoft.Network/virtualHubs',480,470,parent=az,size=80,label='Virtual Hub / 10.89.255.0/24\nCustom hub route table',label_pos='top')
    er=cloud.icon(d,'Microsoft.Network/expressRouteCircuits',920,470,parent=az,size=95,label='External ExpressRoute\ncircuit + hub gateway',label_pos='top')
    drg=d.icon('DRG',550,470,parent=reg,size=90,label='DRG + VCN attachment',label_pos='top')
    d.connect(wan,hub,kind='plain',straight=True)
    d.connect(hub,er,kind='dashed',label='External gateway binding',straight=True,label_offset=(0,30))
    d.connect(hub,subnet,kind='plain',label='Hub/VNet connection / deployVpnGateway=false',exit=(.5,0),entry=(.5,1),waypoints=[(500,550),(570,550)],label_offset=(-120,0))
    d.connect(rt,drg,exit=(.5,1),entry=(.5,0),waypoints=[(2300,560),(1970,560)])
    d.connect(er,drg,kind='fastconnect',label='PRIMARY / FastConnect + ExpressRoute\nExternal circuits / activation / BGP / route policy',exit=(1,.5),entry=(0,.5),straight=True,label_offset=(0,65))
    vpn=cloud.box(d,'Microsoft.Network/virtualNetworkGateways','Classic VNet VPN Gateway / optional alternative\nOff by default / deployVpnGateway=true selects VPN-only mode',70,735,960,125,parent=az,kind='optional',icon_size=75,text_size=18)
    cpe=d.group('optional','',70,735,960,125,parent=reg)
    d.icon('Customer Premises Equipment',70,70,parent=cpe,size=75,label='')
    d.text('Optional OCI CPE + IPSec\nExplicit endpoints / tunnel pairing / static routes',135,20,800,85,parent=cpe,size=18)
    d.connect(vpn,cpe,kind='vpn',label='SEPARATE VPN ALTERNATIVE / disabled by default\nNot concurrent vWAN backup in this implementation',exit=(1,.5),entry=(0,.5),straight=True,label_offset=(0,65))
    d.connect(cpe,drg,kind='plain',label='IPSec drg_id / optional',exit=(.5,0),entry=(.5,1),straight=True)
    d.text('Interconnect design: connect workload VNet to hub.\nClassic VNet VPN mode removes that direct hub connection.\nConcurrent backup requires a separately designed native vHub VPN.',60,925,980,90,parent=az,size=17)
    d.text('Foundation retains IGW + Internet default route, HTTPS security list\nand an optional Notifications topic. No workload is created.\nExpressRoute/FastConnect resources are external prerequisites.',60,925,980,90,parent=reg,size=17)
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
        subnets=[];gateways=[]
        for group,prefix,names in [(hub,hp,['DMZ','FIREWALL','SHARED']),(spoke,sp,['WEB','APP','DB'])]:
            for j,n in enumerate(names):
                subnet=d.group('subnet',f'{n}\n{prefix}.{j}.0/24',100,65+j*120,320,100,parent=group)
                subnets.append(subnet)
                d.text('Public IPs allowed' if group is hub and j==0 else 'Private',15,55,290,30,parent=subnet,size=12)
        for icon,y,label in [('Internet Gateway',120,'IGW'),('NAT Gateway',250,'NAT'),('Service Gateway',380,'SGW')]:
            gateways.append(d.icon(icon,0,y,parent=hub,size=42,label=label,label_pos='left',border=True))
        gateways.append(d.icon('Service Gateway',0,380,parent=spoke,size=42,label='SGW',label_pos='left',border=True))
        base.compact_routes(d,drg,hub,spoke,subnets,gateways)
        d.text('Hub: public RT → IGW; private RT → NAT / SGW. Spoke: default → own DRG; OSN → SGW.\nBaseline lists: empty ingress, all egress. No connection between these foundations is declared.',20,655,1080,45,parent=area,size=11)
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
    targets=d.group('other','Backend targets / operator-supplied ownership and placement',1760,160,700,470)
    d.box('Configured IP addresses or target IDs\nNo backend VMs are created.\nTargets need not be in the NLB subnet.\nHealth, network reachability and security remain to be verified.',25,100,650,180,parent=targets)
    d.connect(config,targets,kind='dashed',exit=(1,.5),entry=(0,.5),waypoints=[(1730,545),(1730,395)])
    iam=d.group('optional','IAM / no policy by default',1760,720,700,290,style_extra='verticalAlign=top;spacingTop=12;')
    d.text('policy_statements=[]\nWhen provided, IAM policy targets tenancy root by default\nor an explicit policy compartment, through the home-region provider.\nThis scope is separate from the network compartment.',25,75,650,140,parent=iam,size=14)
    return d


def expressroute(title,index):
    d=base.build(title,'base',index,subtitle=f'NETWORKING {index:02} / Official OCI Toolkit v24.2 / Source foundation + separate Azure template')
    az=d.group('thirdparty','Azure / separate Bicep template, resource-group location',1760,160,740,1080)
    wan=cloud.box(d,'Microsoft.Network/virtualWans','Standard Virtual WAN + Virtual Hub\nvHub prefix 10.88.255.0/24 (default)\nHub route table: oci-transit label; routes empty',25,80,690,130,parent=az,kind='thirdparty_component')
    er=cloud.box(d,'Microsoft.Network/expressRouteGateways','ExpressRoute Gateway / deploy flag=true\nConnection created only if private-peering ID is nonempty\nCircuit itself is not created',25,300,690,130,parent=az,kind='thirdparty_component')
    net=cloud.box(d,'Microsoft.Network/virtualNetworks','Default Azure VNet app1 / 10.88.10.0/24\nWorkload subnet 10.88.10.0/24 + NSG\nvHub VNet connection associated with route table',25,530,690,130,parent=az,kind='thirdparty_component')
    d.connect(wan,er,kind='plain',straight=True)
    drg=next(n for n in d.nodes if n.kind=='icon' and n.name=='DRG')
    d.connect(drg,er,kind='dashed',label='Optional FastConnect / ExpressRoute: external key + peering',exit=(1,.5),entry=(0,.5),waypoints=[(1725,300),(1725,525)])
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
