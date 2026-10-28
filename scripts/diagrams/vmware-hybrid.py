#!/usr/bin/env python3
"""Three opt-in VMware topologies with explicit circuit ownership and proposed guest apps."""
import argparse,importlib.util
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
def load(name):
 s=importlib.util.spec_from_file_location(name,Path(__file__).with_name(name+'.py'));m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
base=load('ai-industry-batch-03');cloud=load('cloud-icons')
ITEMS=['vmware/ocvs-onprem-hcx','vmware/azure-avs-ocvs-interconnect','vmware/azure-avs-ocvs-onprem-triangle']
def onprem(d,x,triangle=False):
 r=d.group('onprem','On-premises VMware / existing and externally operated',x,160,900,900)
 vc=d.box('Existing vCenter + ESXi / vSAN or selected storage\nNSX / VM networks / guest VMs\nVersions, licensing, capacity and support require review',40,100,820,140,parent=r,kind='optional')
 cloud.icon(d,'VMware.vCenter',60,70,parent=vc,size=40,label='vCenter',label_pos='bottom')
 cloud.icon(d,'VMware.NSXManager',760,70,parent=vc,size=40,label='NSX',label_pos='bottom')
 hcx=d.box('HCX Connector / external installation\nSite pair + compute/network profiles + service mesh per pair\nIX / optional NE and WAN optimization appliances\nNo three-site service mesh or automatic DR',40,365,820,150,parent=r,kind='optional')
 edge=d.box('Existing edge router / firewall / carrier handoff\nDNS + NTP / HCX activation and update egress\n'+('Separate on-premises FastConnect and ExpressRoute legs' if triangle else 'Independent partner FastConnect leg to OCI'),40,640,820,120,parent=r,kind='optional')
 d.connect(hcx,vc,kind='dashed',label='External registration / supported versions',exit=(.5,0),entry=(.5,1),straight=True)
 d.connect(hcx,edge,kind='dashed',label='External HCX routing / scoped rules',exit=(.5,1),entry=(.5,0),straight=True)
 return r,edge,hcx

def oci(d,x):
 r=d.group('region','OCI / explicit compartment and selected region / opt-in',x,160,900,900)
 vc=d.group('vcn','Existing prepared OCVS VCN / CIDRs TBC',40,80,820,600,parent=r)
 sddc=d.box('OCVS SDDC / enable_sddc=false\nMANAGEMENT + explicit WORKLOAD clusters / dense-vSAN\nESXi / vCenter / NSX / HCX when enable_hcx=true\nPinned implementation 94ad890 / no guest VMs created',30,80,760,155,parent=vc)
 cloud.icon(d,'VMware.vCenter',50,65,parent=sddc,size=35,label='vCenter',label_pos='bottom')
 cloud.icon(d,'VMware.NSXManager',710,65,parent=sddc,size=35,label='NSX',label_pos='bottom')
 net=d.box('Existing per-cluster network IDs\nPrivate provisioning subnet + eight baseline VLANs\nOptional HCX / replication VLANs + applicable VCF BYOL\nDedicated IDs / compartment, VCN and AD metadata checks',30,355,760,145,parent=vc,kind='optional')
 d.connect(sddc,net,kind='plain',label='Subnet / VLAN / license references',exit=(.5,1),entry=(.5,0),straight=True)
 drg=d.icon('DRG',450,760,parent=r,size=55,label='Optional DRG + VCN attachment\nenable_transport=false',label_pos='bottom')
 d.connect(drg,vc,kind='plain',label='attachment.network_details.id',exit=(.5,0),entry=(.5,1),straight=True)
 return r,drg,sddc

def azure(d,x):
 r=d.group('thirdparty','Azure / separately deployed Bicep / approved region and quota',x,160,900,900)
 avs=cloud.icon(d,'Microsoft.AVS/privateClouds',450,170,parent=r,size=65,label='AVS private cloud / createPrivateCloud=false\nOr existing same-RG AVS / management + workload networks\nAV36 + 3 hosts + /22 are reviewable examples',label_pos='top')
 hcx=d.box('HCX add-on / enableHcxAddon=false\nExplicit offer + management/uplink networks',40,255,820,70,parent=r)
 d.connect(hcx,avs,kind='plain',label='Optional parent AVS',exit=(.5,0),entry=(.5,1),straight=True)
 managed=d.box('AVS-managed ExpressRoute circuit\nPart of AVS / no standalone customer circuit resource',40,365,820,90,parent=r,kind='optional')
 d.connect(managed,avs,kind='plain',label='Part of AVS',exit=(0,.5),entry=(0,.5),waypoints=[(x+20,570),(x+20,330)])
 gr=d.box('Optional AVS Global Reach attachment + ER authorization\nconnectAvsToOci / costs + region + address-plan gates\navsTransitVerified=false / exact pairing support pending',40,545,820,110,parent=r)
 d.connect(gr,managed,kind='plain',label='AVS parent / service-managed circuit',exit=(.5,0),entry=(.5,1),straight=True)
 er=cloud.icon(d,'Microsoft.Network/expressRouteCircuits',450,760,parent=r,size=60,label='Customer Oracle-facing ExpressRoute\ncreateInterconnectCircuit=false / provider service key\nPrivate peering completed by partner provisioning',label_pos='bottom')
 d.connect(gr,er,kind='plain',label='peerExpressRouteCircuit / authorizationKey',exit=(.5,1),entry=(.5,0),straight=True)
 return r,er,managed,hcx

def workloads(d,width,y=1370,placement='Workload cluster VMs / external proposal'):
 d.text('PROPOSED GENERIC WORKLOAD / '+placement+' / NOT deployed or tested',20,y,width,40,size=19,bold=True)
 step=width/4;nodes=[]
 for i,label in enumerate(['Client / browser\nExisting private entry / HTTPS 443','NGINX web VM\nLinux / TLS termination + proxy','Spring Boot API VM\nLinux / identity and secrets required','PostgreSQL VM\nTLS / backup + WAL archive / restore test']):
  nodes.append(d.box(label,20+i*step,y+75,step-100,115,kind='optional'))
  if i:cloud.icon(d,'VMware.VirtualMachine',30,57.5,parent=nodes[-1],size=32)
 for i,label in enumerate(['HTTPS 443','HTTPS 8443','TLS 5432']):d.connect(nodes[i],nodes[i+1],kind='dashed',label=label,straight=True)
 return nodes

def build(index):
 tri=index==2;has_onprem=index!=1;has_azure=index!=0
 width=2940 if tri else 1920
 title=['On-premises VMware + OCVS | HCX and partner FastConnect','Azure AVS + OCVS | ExpressRoute / FastConnect and proposed Global Reach','VMware triangle | On-premises, OCVS and AVS with three independent legs'][index]
 d=base.network.Diagram(toolkit=base.network.TOOLKIT,title=title)
 d.text(title,20,10,width,45,size=25,bold=True)
 d.text('Plain: declared ID/config associations. Solid: optional circuit intent. Dashed: external prerequisites or proposed apps. No runtime evidence.',20,85,width,45,size=14)
 if has_onprem:op,edge,connector=onprem(d,20,tri)
 oci_x=1040 if has_onprem else 20
 reg,drg,sddc=oci(d,oci_x)
 if has_azure:az,er,managed,cloud_hcx=azure(d,2060 if tri else 1040)
 if has_onprem:
  d.connect(edge,drg,label='Optional partner FastConnect / circuits.onprem / provider handoff external',exit=(1,.5),entry=(0,.5),waypoints=[(970,860),(970,920)],label_offset=(0,25))
 if has_onprem:
  d.connect(connector,sddc,kind='dashed',label='Optional HCX pair',exit=(1,.5),entry=(0,.8),waypoints=[(970,600),(970,444)])
 if has_azure:
  between=1980 if tri else 960
  d.connect(sddc,cloud_hcx,kind='dashed',label='Optional HCX pair',exit=(1,.9),entry=(0,.5),waypoints=[(between,459.5),(between,450)],label_offset=(0,-30))
  d.connect(drg,er,label='Optional PRIVATE VC / circuits.azure / ExpressRoute service key + 2 BGP pairs',exit=(1,.5),entry=(0,.5),straight=True,label_offset=(0,-40))
 if tri:
  remote=d.box('Second AVS Global Reach attachment / onprem-direct\nconnectOnpremToAvs + approved + onpremGlobalReachVerified\nExisting separate onpremCircuitId + secure authorization key',2060,1140,900,130)
  customer=d.group('onprem','Customer direct ExpressRoute / existing carrier circuit',20,1110,900,190)
  customer_er=cloud.icon(d,'Microsoft.Network/expressRouteCircuits',450,95,parent=customer,size=60,label='Customer ExpressRoute / onpremCircuitId',label_pos='top')
  d.text('Independent customer-to-Azure private peering / carrier provisioning external',35,145,830,30,parent=customer,size=14)
  d.connect(edge,customer_er,kind='dashed',label='External customer edge / carrier handoff',exit=(.1,1),entry=(0,.5),waypoints=[(142,1205)],label_offset=(80,-30))
  d.connect(remote,customer_er,kind='plain',label='Direct customer–Azure ExpressRoute / onpremCircuitId + authorizationKey',exit=(0,.5),entry=(1,.5),straight=True,label_offset=(0,25))
  d.connect(remote,managed,kind='plain',label='AVS parent',exit=(1,.5),entry=(1,.5),waypoints=[(3040,1205),(3040,570)],label_offset=(0,-30))
 else:
  d.text('HCX site pairing / profiles / service meshes and source-to-target VM migration remain external steps.\nPrivate circuits alone do not configure application access, database consistency, replication, backup or failover.',20,1130,width,105,size=18)
 placement=['Move a complete three-tier VM stack from onprem to OCVS in controlled waves','Example: web/API on AVS, database on OCVS; measure latency before accepting split tiers','Start onprem, pilot on AVS, final target OCVS; keep each active stack colocated'][index]
 workloads(d,width,1370,placement)
 d.box('DISABLED DEFAULTS / no cloud resources or network reads. Costs, offering/region, CIDRs, BGP, security, routes, MTU, DNS/NTP and licensing require review.\nOCI creates optional SDDC/DRG/attachment/partner VCs; existing VCN/subnets/VLANs, NSX routing and firewall policy remain external.\nAVS-to-Oracle Global Reach is a proposed pairing requiring vendor confirmation. A VNet gateway does not transit two circuits; onprem needs independent cloud legs.\nNo site pairing, guest VM, package, database, backup, replication or automatic failover is deployed. Complete source inventory and input pages accompany this overview.',20,1630,width,155,kind='note')
 d.text('Review 2026-10-28 / local schema, isolated mocked wrapper plans and Bicep compilation only. No paid activation, cloud deployment, HCX session, migration or application test.',20,1820,width,60,size=13)
 return d

def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--render',action='store_true');p.add_argument('--blueprint',action='append',choices=ITEMS);a=p.parse_args()
 for i,slug in enumerate(ITEMS):
  if a.blueprint and slug not in a.blueprint:continue
  d=build(i);w=d.check()+d._crossings([n for n in d.nodes if n.kind=='text']);print(slug,w,flush=True)
  if w:raise RuntimeError('Fix geometry')
  path=ROOT/'blueprints'/slug/'architecture/architecture.drawio';d.save(str(path))
  if a.render and not d.render(str(path.with_suffix('.png')),scale=1.5):raise RuntimeError('PNG export failed')
  with path.open('a') as f:f.write('\n')
if __name__=='__main__':main()
