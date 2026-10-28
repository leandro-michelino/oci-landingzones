#!/usr/bin/env python3
"""Illustrative topology only; no mapping to a deployable blueprint."""
import importlib.util
from pathlib import Path
spec=importlib.util.spec_from_file_location('network',Path(__file__).with_name('networking-batch-01.py'))
base=importlib.util.module_from_spec(spec);spec.loader.exec_module(base)
def build():
 d=base.Diagram(toolkit=base.TOOLKIT,title='Conceptual three-tier application with private Autonomous Database')
 d.text('Conceptual three-tier application | Private Autonomous Database',20,10,2450,45,size=25,bold=True)
 d.text('ILLUSTRATIVE DESIGN / All workloads and paths require separate configuration; no blueprint deployment evidence',20,70,2450,30,size=14)
 reg=d.group('region','OCI region / operator selected',280,160,1840,900)
 vc=d.group('vcn','Example VCN\n10.0.0.0/16 / illustrative addressing',40,70,1760,730,parent=reg)
 web=d.group('subnet','Public web subnet\n10.0.1.0/24 / example',80,100,470,440,parent=vc)
 app=d.group('subnet','Private application subnet\n10.0.2.0/24 / example',650,100,470,440,parent=vc)
 data=d.group('subnet','Private database endpoint subnet\n10.0.3.0/24 / example',1250,100,440,440,parent=vc)
 lb=d.icon('Load Balancer',110,235,parent=web,size=60,label='Public HTTPS LB',label_pos='top')
 webs=[d.icon('Compute',350,y,parent=web,size=52,label='Web VM '+str(i+1),label_pos='top') for i,y in enumerate([150,335])]
 apps=[d.icon('Compute',220,y,parent=app,size=52,label='App VM '+str(i+1),label_pos='top') for i,y in enumerate([150,335])]
 db=d.icon('Oracle Autonomous Database',220,235,parent=data,size=70,label='ADB private endpoint',label_pos='top')
 igw=d.icon('Internet Gateway',0,335,parent=vc,size=52,label='IGW',label_pos='top',border=True)
 nat=d.icon('NAT Gateway',700,730,parent=vc,size=52,label='NAT / outbound only',label_pos='top',border=True)
 sg=d.icon('Service Gateway',1100,730,parent=vc,size=52,label='SGW',label_pos='top',border=True)
 public=d.group('internet','Internet / client',20,440,200,200)
 client=d.icon('Internet',100,95,parent=public,size=52,label='HTTPS / TCP 443',label_pos='bottom')
 d.connect(client,igw,label='443',straight=True)
 d.connect(igw,lb,label='Public frontend',exit=(1,.5),entry=(0,.5),waypoints=[(370,565)])
 for i in range(2):
  d.connect(lb,webs[i],label='HTTPS' if i==0 else '',exit=(1,.5),entry=(0,.5),waypoints=[(650,565),(650,webs[i].center()[1])])
  d.connect(webs[i],apps[i],label='Application port TBC',straight=True)
  d.connect(apps[i],db,label='mTLS / TCP 1522' if i==0 else '',exit=(1,.5),entry=(0,.3 if i==0 else .7),waypoints=[(1480,apps[i].center()[1]),(1480,db.center()[1]+(-14 if i==0 else 14))])
 d.connect(apps[1],nat,label='Default route / egress',exit=(.5,1),entry=(.5,0),waypoints=[(1190,875),(1020,875)])
 d.connect(apps[1],sg,label='Regional OSN service route',exit=(1,.5),entry=(.5,0),waypoints=[(1380,665),(1380,875),(1420,875)])
 outbound=d.group('internet','Internet / updates',20,890,200,200)
 out=d.icon('Internet',100,85,parent=outbound,size=48,label='Same Internet',label_pos='bottom')
 d.connect(nat,out,exit=(.5,1),entry=(.5,1),waypoints=[(1020,1120),(120,1120)])
 osn=d.group('osn','Oracle Services Network',2200,800,320,250)
 services=d.icon('Oracle Services Network',160,95,parent=osn,size=56,label='Supported regional services',label_pos='bottom')
 d.connect(sg,services,exit=(.5,1),entry=(0,.5),waypoints=[(1420,1090),(2160,1090),(2160,895)])
 d.text('Illustrative route and security intent only. NSGs, route tables, return paths, DNS, TLS certificates and availability placement require design and configuration.\nDatabase traffic uses the private endpoint; the Service Gateway path reaches regional Oracle services. NAT has no inbound client path.',360,1140,2100,65,size=14)
 d.box('CONCEPTUAL SCOPE: Solid arrows show proposed request / outbound paths, not Terraform-created bindings or working sessions.\nNo cloud resources, runtime connectivity or failover were validated. Example CIDRs are not inventory.\nEditable draw.io and PNG regenerated with official OCI Toolkit v24.2 on 2026-10-28.',20,1220,2500,140,kind='note')
 return d
if __name__=='__main__':
 d=build();assert not d.check(),d.check()
 path=base.ROOT/'docs/diagrams/oci-3tier-adb.drawio'
 d.save(str(path));assert d.render(str(path.with_suffix('.png')),scale=1.5)
 with path.open('a') as stream:stream.write('\n')
