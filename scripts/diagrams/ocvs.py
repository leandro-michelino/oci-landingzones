#!/usr/bin/env python3
"""OCVS SDDC on prepared networking; no provisioning or inferred migration path."""
import argparse
import importlib.util
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
SLUG='vmware/ocvs'
def load(name):
 spec=importlib.util.spec_from_file_location(name,Path(__file__).with_name(name+'.py'))
 m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
base=load('ai-industry-batch-03')
def build():
 title='Oracle Cloud VMware Solution | Optional dense/vSAN SDDC on prepared private networking'
 d=base.network.Diagram(toolkit=base.network.TOOLKIT,title=title)
 d.text(title,20,10,2460,45,size=25,bold=True)
 d.text('VMWARE / OCVS / Source configuration / VMware components use named boxes; no substitute service icons',20,65,2460,30,size=13)
 d.text('Plain: ID bindings. FastConnect badge: required external private transport. Dashed: external migration prerequisites. No runtime evidence.',20,108,2460,30,size=13)
 corp=d.group('onprem','Existing corporate VMware environment / EXTERNAL',20,240,320,350)
 d.text('Source vCenter / ESXi / guest VMs\nRemote HCX appliances if needed\nMigration tools, licensing and runbooks\nNot created or configured by this blueprint',20,100,280,180,parent=corp,size=16)
 transport=d.box('Existing customer edge + carrier handoff\nPrivate FastConnect to OCI / EXTERNAL\nRoutes, BGP, DNS and security required\nNot created or activated by this blueprint',20,740,320,180,kind='optional')
 d.connect(corp,transport,kind='dashed',label='External access / migration prerequisites',exit=(.5,1),entry=(.5,0),straight=True)
 r=d.group('region','OCI / selected region and explicit workload compartment / single AD',400,160,2060,900)
 vc=d.group('vcn','Existing prepared OCVS VCN\nCIDR TBC / not created',35,80,1990,720,parent=r)
 sn=d.group('subnet','Existing ESXi provisioning subnets / per cluster\nCIDR TBC / public IPs prohibited',40,100,650,175,parent=vc)
 d.text('MANAGEMENT + each WORKLOAD use dedicated subnet IDs\nRead-only metadata checks when opted in\nNo subnet, NSG, route table or gateway creation',20,95,610,60,parent=sn,size=15)
 sddc=d.box('Optional OCVS SDDC / enable_sddc=false\nOne MANAGEMENT + explicit WORKLOAD clusters / 3-64 hosts each\nDense/vSAN only / explicit AD, shape, VMware bundle and commitment\nService-managed ESXi + vCenter + NSX control plane; no guest VMs',800,100,1110,175,parent=vc)
 load('cloud-icons').icon(d,'VMware.vCenter',55,65,parent=sddc,size=40,label='vCenter',label_pos='bottom')
 load('cloud-icons').icon(d,'VMware.NSXManager',1055,65,parent=sddc,size=40,label='NSX',label_pos='bottom')
 d.connect(sn,sddc,kind='plain',label='provisioning_subnet_id',straight=True)
 vlans=d.box('Existing VLAN identifier bindings / eight baseline roles per cluster\nvSphere / vMotion / vSAN / NSX host VTEP / NSX Edge VTEP\nNSX Edge uplink 1 / uplink 2 / Provisioning-Net\nAll clusters use distinct VLAN IDs; same VCN + compartment; compatible AD\nSelected optional HCX / Replication-Net IDs extend this map',40,355,1200,165,parent=vc)
 d.connect(vlans,sddc,kind='plain',label='VLAN role bindings',exit=(.6,0),entry=(0,.8),waypoints=[(1195,480)])
 hcx=d.box('Optional existing HCX VLAN\nMANAGEMENT only / enable_hcx=true\nRemote HCX / licensing / vSphere NAT routing\nEXTERNAL prerequisites; no pairing executed',1390,355,520,165,parent=vc,kind='optional')
 d.connect(hcx,vlans,kind='plain',label='Optional HCX ID',straight=True)
 repl=d.box('Optional existing Replication-Net VLAN\nPassed when supplied; required for applicable bundles, including VMware 7.x\nNo replication job, channel, schedule or tested DR is created',40,570,1200,95,parent=vc,kind='optional')
 d.connect(repl,vlans,kind='plain',label='Optional replication_vlan_id',exit=(.5,0),entry=(.5,1),straight=True)
 byol=d.box('Optional existing per-cluster VCF BYOL IDs\nGlobal default / per-WORKLOAD override\nNo license purchase or allocation created',1390,570,520,95,parent=vc,kind='optional')
 d.connect(byol,sddc,kind='plain',label='BYOL ID / optional',exit=(1,.5),entry=(1,.8),waypoints=[(2390,857.5),(2390,480)])
 drg=d.icon('DRG',100,840,parent=r,size=55,label='Existing DRG / EXTERNAL',label_pos='bottom')
 d.connect(transport,drg,kind='fastconnect',label='FastConnect PRIVATE\nEXTERNAL / required',exit=(1,.5),entry=(0,.5),waypoints=[(365,830),(365,1000)],label_offset=(-110,0))
 d.connect(drg,vc,kind='plain',label='Existing VCN attachment / external',exit=(1,.5),entry=(.15,1),waypoints=[(733.5,1000),(733.5,960)],label_offset=(0,25))
 d.text('Metadata lookups check only VCN/compartment, private provisioning subnet, distinct VLAN IDs and AD compatibility.\nNo complete security/routing/MTU/DNS audit, host capacity, licensing eligibility, migration, management login or application traffic is verified.',400,820,1620,60,parent=r,size=15)
 d.box('DEFAULT RESULT: No OCI resources or lookups. Only the local terraform_data guard exists; enable_sddc=false, inspect_existing_network=false and costs_approved=false.\nCreation requires explicit reviewed costs, network IDs, supported dense shape/bundle/commitment, AD and RSA public SSH key. Read-only inspection can be enabled separately.\nOne cloud resource declaration provisions the SDDC and its initial service-managed clusters/components; it does not duplicate ESXi hosts as individual Terraform resources.\nNo network or external-site resources are created. Optional workload CIDR is an initial NSX input, not guest provisioning. Password outputs are absent; protect deployment state and saved plans.',20,1150,2460,135,kind='note')
 load('vmware-hybrid').workloads(d,2460,1450,'All three tiers on OCVS guest VMs / no industry dependency')
 return d
def main():
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--render',action='store_true');args=parser.parse_args()
 d=build();warnings=d.check()+d._crossings([n for n in d.nodes if n.kind=='text']);print(SLUG,warnings,flush=True)
 if warnings:raise RuntimeError('Fix layout before export')
 path=ROOT/'blueprints'/SLUG/'architecture/architecture.drawio';d.save(str(path))
 if args.render and not d.render(str(path.with_suffix('.png')),scale=1.5):raise RuntimeError('PNG export failed')
 with path.open('a') as f:f.write('\n')
if __name__=='__main__':main()
