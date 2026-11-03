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
icon_spec=importlib.util.spec_from_file_location('cloud_icons',Path(__file__).with_name('cloud-icons.py'))
provider_icons=importlib.util.module_from_spec(icon_spec); icon_spec.loader.exec_module(provider_icons)
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
    subnets=[];gateways=[]
    for vcn,prefix,names in [(hub,'10.0',['DMZ','FIREWALL','SHARED']),(spoke,'10.1',['WEB','APP','DB'])]:
        for i,name in enumerate(names):
            sn=d.group('subnet',f'{name}\n{prefix}.{i}.0/24',100,65+i*120,290,100,parent=vcn)
            subnets.append(sn)
            d.text('Public IPs allowed' if vcn is hub and i==0 else 'Private',15,55,260,30,parent=sn,size=12)
    for name,y in [('Internet Gateway',120),('NAT Gateway',250),('Service Gateway',380)]:
        gateways.append(d.icon(name,0,y,parent=hub,size=42,label={'Internet Gateway':'IGW','NAT Gateway':'NAT','Service Gateway':'SGW'}[name],label_pos='left',border=True))
    gateways.append(d.icon('Service Gateway',0,380,parent=spoke,size=42,label='SGW',label_pos='left',border=True))
    base.compact_routes(d,drg,hub,spoke,subnets,gateways)
    d.text('Hub: public RT → IGW; private RT → NAT / SGW. Spoke: default route → DRG; OSN route → SGW.\nShared baseline lists: no ingress; all egress. Gateways shown on VCN edges; no workload resources.',20,660,1020,45,parent=comp,size=11)


def dual(title,index):
    d=header(title,index)
    regional(d,20,'Primary region / required operator input')
    regional(d,1200,'Secondary region / eu-amsterdam-1 default')
    d.box('NO INTER-REGION LINK IS DECLARED\nTwo separate hub/spoke foundations and regional DRGs. No RPC, replication, application failover or DR orchestration is created.',20,1020,2280,110,kind='note')
    d.box('ADDRESSING / DEFAULTS\nBoth module calls inherit the same hub 10.0.0.0/16 and spoke 10.1.0.0/16 CIDRs. Do not infer routable inter-region connectivity.\nThe wrapper does not expose network CIDR overrides; connected designs require a reviewed addressing/configuration change.',20,1180,2280,110,kind='note')
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
        d.connect(view,resolver,kind='plain',label='attached_views / view_id',exit=(1,.5),entry=(1,.3),waypoints=[(2485,360),(2485,763)])
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
    title=('AWS + OCI | Managed Interconnect primary, optional VPN' if aws else 'Azure + OCI | FastConnect + ExpressRoute primary, optional VPN')
    d=base.Diagram(toolkit=base.TOOLKIT,title=title)
    d.text(title,20,10,2500,45,size=25,bold=True)
    d.text('Primary design: supported native Interconnect / dashed links require external provisioning; solid links show source configuration.',20,70,2500,35,size=15)
    remote=d.group('thirdparty','AWS us-east-1 / N. Virginia' if aws else 'Azure / South Africa North example / ExpressRoute location Johannesburg',20,160,1100,1000)
    region=d.group('region','OCI us-ashburn-1 / Ashburn' if aws else 'OCI af-johannesburg-1 / Johannesburg example',1420,160,1100,1000)
    cidr='10.94' if aws else '10.88'
    oc='10.54' if aws else '10.58'
    vpc=d.group('thirdparty',('VPC' if aws else 'VNet')+' / '+cidr+'.0.0/16 (source default)',40,80,1020,200,parent=remote)
    subnet=d.box('Workload subnet / '+cidr+'.10.0/24 (source default)\nSeparate '+('CloudFormation' if aws else 'Bicep')+' foundation / no application created',30,65,960,100,parent=vpc)
    vcn=d.group('vcn','OCI backbone VCN / '+oc+'.0.0/16 (source default)',40,80,1020,200,parent=region)
    sn=d.group('subnet','Backbone subnet / '+oc+'.10.0/24',30,65,650,100,parent=vcn)
    rt=d.icon('Route Table',840,115,parent=vcn,size=48,label='Remote prefixes → DRG\nDedicated OR VPN mode',label_pos='top')
    d.connect(sn,rt,kind='plain',straight=True)
    drg=d.icon('DRG',550,470,parent=region,size=65,label='DRG + VCN attachment\nCircuit must attach to this DRG',label_pos='top')
    d.connect(rt,drg,exit=(.5,1),entry=(.5,0),waypoints=[(2300,520),(1970,520)])
    primary=d.box(('External DXGW + TGW association\nNative managed Interconnect / accept activation key' if aws else 'External ExpressRoute circuit + private peering\nExpressRoute VNet gateway + VNet connection'),70,400,960,125,parent=remote,kind='optional')
    d.connect(primary,subnet,kind='dashed',label='External '+('DXGW/TGW association + VPC routing' if aws else 'ExpressRoute gateway connection / return routes'),exit=(.5,0),entry=(.5,1),straight=True)
    d.connect(primary,drg,kind='dashed',label='PRIMARY / '+('Managed Interconnect + FastConnect VC' if aws else 'ExpressRoute + FastConnect VC'),exit=(1,.5),entry=(0,.5),straight=True,label_offset=(0,50))
    vpn=provider_icons.box(d,'AWS::EC2::TransitGateway' if aws else 'Microsoft.Network/virtualNetworkGateways',('TGW + optional static-route VPN' if aws else 'Optional VPN gateway + BGP connection')+'\nCompanion template / separate deployment',70,720,960,110,parent=remote,kind='thirdparty_component')
    ipsec=d.box('Optional OCI CPE + IPSec\nExplicit remote public endpoint / static routes',70,720,960,110,parent=region,kind='optional')
    d.connect(vpn,ipsec,kind='vpn',label='OPTIONAL BACKUP / external tunnel pairing + tested route preference',straight=True,label_offset=(0,50))
    d.connect(ipsec,drg,kind='plain',label='drg_id',exit=(.5,0),entry=(.5,1),straight=True)
    d.text('Source foundation also declares '+('flow logs, KMS and log-delivery IAM.\nTGW/VPC attachment remains managed by the companion template.' if aws else 'Internet UDR, NSG, public IP and VPN edge when enabled.\nIt does not create ExpressRoute resources.'),60,890,980,80,parent=remote,size=15)
    d.text('Source foundation retains IGW + Internet default route, public-IP-capable\nsubnet, HTTPS security list and optional Notifications topic.\nCircuit IDs record a handoff; this root creates neither primary circuit.',60,890,980,80,parent=region,size=15)
    d.box(('MANAGED AWS: us-ashburn-1 ↔ us-east-1 only. One logical circuit includes provider device/location redundancy + MACsec.\nUse aws-oci-managed-interconnect for a NEW private VGW foundation; its resources are separate from this TGW backbone.\nOther region pairs: independently assess carrier Direct Connect + FastConnect or VPN; do not assume native service availability.' if aws else 'AZURE: 12 OCI connection locations / full matrix in docs/multicloud/INTERCONNECT-REGIONS.md.\nNative FastConnect + ExpressRoute includes redundant BGP sessions; private transport alone does not imply encryption.\nExisting circuit IDs, ExpressRoute gateway attachment, route filters and private DNS require explicit operator provisioning.'),20,1230,2500,150,kind='note')
    d.text('CIDRs are editable examples. Keep Internet defaults under review for production. Native cloud-to-cloud Interconnect does not support on-premises transit.\nVPN-only defaults are retained for compatibility; select dedicated mode explicitly. Route preference, DNS and failover require configuration and acceptance tests.',20,1410,2500,75,size=15)
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
