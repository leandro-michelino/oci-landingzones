#!/usr/bin/env python3
"""Private healthcare project: source-backed infrastructure, explicit external handoffs."""
import importlib.util
from pathlib import Path
spec=importlib.util.spec_from_file_location('base',Path(__file__).with_name('networking-batch-01.py'))
base=importlib.util.module_from_spec(spec);spec.loader.exec_module(base)
SLUG='industry/healthcare-platform'
def build():
 d=base.Diagram(toolkit=base.TOOLKIT,title='Healthcare platform | Private application and patient-data infrastructure')
 d.text('Healthcare platform | Private application and patient-data infrastructure',20,10,2660,45,size=25,bold=True)
 d.text('All cloud creation disabled by default / Explicit compartment + cost approval / Single region / No clinical application or compliance certification',20,70,2660,30,size=14)
 d.text('Solid arrows: declared network/backend/log configuration. Plain: resource references. Dashed: external transport or application workflow. No line proves working traffic.',20,112,2660,30,size=13)
 hospital=d.group('onprem','Hospital / externally managed',20,200,280,700)
 client=d.box('Clinical users / approved clients\nhospital_client_cidrs=[]\nExisting remote network',20,100,240,140,parent=hospital)
 identity=d.box('External identity / SSO / MFA\nApplication authorization\nNot deployed here',20,410,240,125,parent=hospital,kind='optional')
 d.connect(identity,client,kind='dashed',label='External identity integration',straight=True)
 reg=d.group('region','OCI / approved region and explicit workload compartment',360,160,2240,1140)
 vc=d.group('vcn','Private project VCN\n10.120.0.0/16 / example',30,80,2180,670,parent=reg)
 sns=[]
 for name,cidr,x,w in [('Ingress','10.120.10.0/24',50,550),('Application','10.120.20.0/24',750,600),('Database','10.120.30.0/24',1530,560)]:
  sn=d.group('subnet',name+' subnet\n'+cidr,x,120,w,350,parent=vc);sns.append(sn)
 lb=d.icon('Load Balancer',275,160,parent=sns[0],size=70,label='Internal HTTPS LB / optional',label_pos='top')
 app=d.icon('OCI Compute',250,160,parent=sns[1],size=70,label='Private app VMs / optional',label_pos='top')
 db=d.icon('Oracle Autonomous Database',280,160,parent=sns[2],size=70,label='ADB private endpoint / optional',label_pos='top')
 d.text('Frontend TLS certificate + listener\n443 ingress: approved hospital prefixes\nHTTPS backend set / trusted CA IDs\nTCP 443 probe; no clinical health check',25,235,500,90,parent=sns[0],size=14)
 d.text('Approved prebuilt HTTPS image + AD per node\nPrivate VNIC / IMDSv2 / customer-key boot disk\nNo application install or identity bootstrap\nNSGs: LB 443; DB 1522; OSN HTTPS egress',25,235,550,90,parent=sns[1],size=14)
 d.text('OLTP / 2 ECPU / 1 TB examples\nmTLS required / autoscaling off\n31-day backup retention input\nCredentials + wallet/application wiring external',25,235,510,90,parent=sns[2],size=14)
 d.connect(lb,app,label='Configured HTTPS backends / 443',straight=True)
 d.connect(app,db,kind='dashed',label='External DB client / mTLS 1522',straight=True)
 rt=d.icon('Route Table',250,540,parent=vc,size=50,label='Shared private RT',label_pos='top')
 drg=d.icon('DRG',0,540,parent=vc,size=55,label='Existing DRG\nNew VCN attachment if supplied',label_pos='bottom',border=True)
 sgw=d.icon('Service Gateway',2180,540,parent=vc,size=55,label='SGW / regional OSN only',label_pos='top',border=True)
 for i,sn in enumerate(sns):
  x=sn.center()[0]
  d.connect(sn,rt,kind='plain',exit=(.5,1),entry=(.5,0),waypoints=[(x,735-8*i),(640,735-8*i)])
 d.connect(rt,drg,label='Hospital prefixes / existing DRG',straight=True)
 d.connect(rt,sgw,label='Regional OSN service route',straight=True)
 d.connect(client,drg,kind='dashed',label='Existing hospital transport + return routes',exit=(1,.5),entry=(0,.5),waypoints=[(330,370),(330,780)])
 d.connect(drg,lb,kind='dashed',label='External client route / NSG permits 443',exit=(.5,0),entry=(0,.5),waypoints=[(390,520)])
 d.text('No IGW, NAT or Internet default route. Empty attached security list; tier NSGs.\nExternal routing, DNS, KMS permissions, identity and app integration need verification.',40,770,650,40,parent=reg,size=12)
 key=d.box('EXISTING KMS key / kms_key_id\nBoot volumes + ADB + bucket reference this key\nNo Vault, key, IAM policy or dynamic group created\nkms_policies_ready=false / operator prerequisite',40,820,560,180,parent=reg,kind='optional')
 logs=d.icon('Logging',1000,910,parent=reg,size=65,label='3 subnet flow logs + log group\n30 days / network metadata only',label_pos='top')
 # Three subnet source configurations target the log group; shared band avoids workload labels.
 for i,sn in enumerate(sns):
  x=[1080,1800,2540][i];y=945+10*i
  d.connect(sn,logs,label='Subnet OCISERVICE flowlogs' if i==1 else '',exit=(1,.85),entry=(.5,0),waypoints=[(x,sn.abs[1]+.85*sn.h),(x,y),(1360,y)])
 osn=d.group('osn','Regional OSN / managed document storage',1460,820,700,180,parent=reg)
 bucket=d.icon('OCI Object Storage',350,80,parent=osn,size=65,label='Documents / optional\nNoPublicAccess / versioned / customer KMS',label_pos='bottom')
 d.connect(sgw,osn,label='Service gateway path',exit=(1,.5),entry=(1,.5),waypoints=[(2585,780),(2585,1070)])
 d.connect(app,bucket,kind='dashed',label='External document SDK / IAM authorization',exit=(1,.5),entry=(0,.5),waypoints=[(1780,520),(1780,1060)])
 d.connect(key,app,kind='plain',label='Boot kms_key_id',exit=(.5,1),entry=(1,.8),waypoints=[(680,1220),(1760,1220),(1760,541)])
 d.connect(key,db,kind='plain',label='ADB kms_key_id',exit=(.8,1),entry=(1,.8),waypoints=[(848,1250),(2640,1250),(2640,541)])
 d.connect(key,bucket,kind='plain',label='Bucket kms_key_id',exit=(1,.8),entry=(.5,1),waypoints=[(1000,1124),(1000,1190),(2170,1190)])
 backup=d.box('Existing boot-volume backup policy\nAssignment per app VM / restore not tested',1000,1320,600,70,kind='optional')
 d.connect(app,backup,kind='plain',label='Boot-volume backup assignment',exit=(1,.2),entry=(1,.5),waypoints=[(1745,499),(1745,1355)])
 d.box('DEFAULT: Local guard contract only; no cloud resources. enable_foundation/application/database/documents=false; costs_approved=false.\nApplication and data services require an existing KMS key and reviewed permissions. Application also requires images, TLS, trusted CAs, backup policy, DRG and client prefixes.\nNo patient data, clinical application, PACS/FHIR server, identity, cross-region DR or regulatory certification is delivered. Bucket IAM/network-source restrictions remain operator work.',20,1450,2660,155,kind='note')
 return d
if __name__=='__main__':
 d=build();warnings=d.check()+d._crossings([n for n in d.nodes if n.kind=='text']);assert not warnings,warnings
 path=base.ROOT/'blueprints'/SLUG/'architecture/architecture.drawio'
 d.save(str(path));assert d.render(str(path.with_suffix('.png')),scale=1.5)
 with path.open('a') as f:f.write('\n')
