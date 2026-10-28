#!/usr/bin/env python3
"""Five source-bound Compliance/DR diagrams with the OCI diagram skill.

Requires Oracle's official v24.2 toolkit and the installed skill.
Run --render for PNG export through draw.io; no cloud calls.
"""
import argparse
import importlib.util
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
spec=importlib.util.spec_from_file_location('networking_batch_02',Path(__file__).with_name('networking-batch-02.py'))
base=importlib.util.module_from_spec(spec); spec.loader.exec_module(base)
ITEMS=[
 ('compliance/zero-trust','Zero Trust pattern | Default network and explicit controls','zero'),
 ('compliance/healthcare-pci','Healthcare / PCI pattern | Optional guardrails','health'),
 ('compliance/security-posture','Security posture | Opt-in resources and automation hooks','posture'),
 ('disaster-recovery/fsdr','Full Stack DR | Protection-group association','fsdr'),
 ('disaster-recovery/azure-oci-cross-cloud-dr','Azure + OCI DR | Separate foundations and contracts','azure'),
]


def header(title,index):
 d=base.Diagram(toolkit=base.TOOLKIT,title=title)
 d.text(title,20,10,2460,45,size=25,bold=True)
 d.text(f'COMPLIANCE / DR {index:02} / Official OCI Toolkit v24.2 / Source defaults, not operational evidence',20,65,2460,30,size=13)
 return d


def footer(d,text,y=1200):
 d.box(text,20,y,2460,135,kind='note')
 d.text('Source review: 2026-10-28. No cloud provisioning, provider revalidation, compliance certification, packet test or recovery drill.\nPlacement values are source defaults or marked operator inputs. Arrows are configuration relationships / stated route intent, not verified runtime behavior.',20,y+170,2460,65,size=12)


def zero(title,index):
 d=header(title,index)
 reg=d.group('region','OCI / selected region',20,160,1400,850)
 comp=d.group('compartment','Network compartment override or Core network compartment',20,50,1360,770,parent=reg)
 vc=d.group('vcn','Three-tier VCN\n10.30.0.0/16 (default)',40,70,1280,620,parent=comp)
 sub=[]
 for i,name in enumerate(['WEB','APP','DB']):
  sn=d.group('subnet',f'{name}\n10.30.{i}.0/24',100,70+170*i,650,120,parent=vc)
  d.text('Public IPs allowed; TCP 80/443 ingress from 0.0.0.0/0' if i==0 else 'Private; baseline has no ingress rules',20,70,610,35,parent=sn,size=13)
  sub.append(sn)
 pr=d.icon('Route Table',1000,130,parent=vc,size=48,label='Public RT / default → IGW',label_pos='top')
 rt=d.icon('Route Table',1000,420,parent=vc,size=48,label='Private RT\nDefault → NAT / OSN label → SGW',label_pos='bottom')
 igw=d.icon('Internet Gateway',1280,130,parent=vc,size=50,label='IGW',label_pos='top',border=True)
 nat=d.icon('NAT Gateway',1280,330,parent=vc,size=50,label='NAT / outbound only',label_pos='top',border=True)
 sgw=d.icon('Service Gateway',1280,510,parent=vc,size=50,label='SGW',label_pos='top',border=True)
 d.connect(sub[0],pr,kind='plain',straight=True); d.connect(pr,igw,straight=True)
 for i in (1,2):
  d.connect(sub[i],rt,kind='plain',exit=(1,.5),entry=(0,.5),waypoints=[(960,410+170*i),(960,700)])
 d.connect(rt,nat,exit=(1,.5),entry=(0,.5),waypoints=[(1220,700),(1220,610)])
 d.connect(rt,sgw,exit=(1,.5),entry=(0,.5),waypoints=[(1220,700),(1220,790)])
 internet=d.group('internet','Internet',1480,280,300,250)
 inet=d.icon('Internet',150,90,parent=internet,size=52,label='Public web route / egress',label_pos='bottom')
 d.connect(igw,inet,straight=True)
 d.text('NAT also provides private-tier\noutbound internet egress.',15,175,270,55,parent=internet,size=12)
 osn=d.group('osn','Oracle Services Network',1480,660,300,250)
 osni=d.icon('Oracle Services Network',150,90,parent=osn,size=52,label='Supported regional services',label_pos='bottom')
 d.connect(sgw,osni,straight=True)
 panel=d.group('other','Core and ZPR control scope',1850,160,700,850)
 d.text('Pinned Core / cis_level=level2\nRoot + 4 child compartments; default IAM groups,\ndynamic groups, scoped policies, tags and logging.',20,70,660,90,parent=panel,size=13)
 for name,x,label in [('Cloud Guard',110,'Cloud Guard / on'),('Vault',350,'Vault + key / on'),('Vulnerability Scanning',590,'VSS / on')]:
  d.icon(name,x,250,parent=panel,size=48,label=label,label_pos='top')
 d.text('Tenancy-wide Cloud Guard configuration + 365-day Audit retention.\nEvents enabled; Monitoring, Budgets and Security Zones disabled.',20,335,660,65,parent=panel,size=12)
 d.box('ZPR / tenancy root / disabled by default\nOnboarding requires home_region == region.\nPolicy map has empty starter statements.\nNo workload security-attribute assignment is declared.',25,490,650,160,parent=panel,kind='optional')
 footer(d,'DEFAULT NETWORK IS NOT PRIVATE-ONLY: Web is public; app/database ingress is empty and all tiers allow egress.\nZPR flags are false. Routes, IAM and service creation do not prove Zero Trust enforcement or complete authorization policy.\nNo workloads, NSGs, app/database sessions or policy-enforcement tests are created by this diagram. No compliance certification is implied.')
 return d


def health(title,index):
 d=header(title,index)
 home=d.group('other','Home-region provider / coalesce(home_region, region)',20,160,2460,330)
 for i,(name,label,text) in enumerate([
  ('Policies','Optional IAM guardrail policy','guardrail_policy_statements=[]\nPolicy compartment defaults to tenancy root.'),
  ('Cloud Advisor','Optional budget + alert','enable_budget=false; monthly amount input=1000\nAlert: ACTUAL / 80 percent; created only if recipients non-null.')]):
  group=d.group('optional',label,30+i*1220,60,1180,220,parent=home,style_extra='verticalAlign=top;spacingTop=12;')
  if i==0: d.icon(name,100,100,parent=group,size=52,label='',label_pos='top')
  d.text(text,200 if i==0 else 30,65,940 if i==0 else 1120,115,parent=group,size=15)
 reg=d.group('region','Regional Data Safe registration / operator region',20,550,2460,480)
 comp=d.group('compartment','Target compartment / supplied or tenancy fallback',20,60,2420,390,parent=reg)
 existing=d.box('Existing database / external prerequisite\nAUTONOMOUS_DATABASE is the default type\nDatabase OCID defaults null; no database is created',30,100,1030,170,parent=comp,kind='thirdparty_component')
 opt=d.group('optional','Data Safe target / enable_data_safe_target_database=false',1190,70,1190,250,parent=comp,style_extra='verticalAlign=top;spacingTop=12;')
 target=d.icon('Data Safe',110,120,parent=opt,size=60,label='Target registration',label_pos='top')
 d.text('Requires an existing Autonomous Database ID for default type.\nCredentials are included only when username and password are both supplied.\nNo assessments, audit collection or masking jobs are declared.',250,70,910,135,parent=opt,size=14)
 d.connect(existing,target,kind='dashed',straight=True)
 footer(d,'DEFAULT RESULT: No resources. This folder declares an optional IAM policy, budget/alert and Data Safe database target registration.\nIt creates no Core foundation, network, Vault, scanning service or application. Budget values are source input defaults, not estimated or actual spend.\nThe Healthcare / PCI title does not establish regulatory compliance; registration does not prove database security or assessment coverage.',1100)
 return d


def posture(title,index):
 d=header(title,index)
 reg=d.group('region','OCI selected region / target compartment input (tenancy fallback)',20,160,2460,930)
 items=[
  ('Cloud Guard','Cloud Guard target / create=false','No tenancy-wide Cloud Guard configuration declared.\nTarget scope defaults to selected compartment; recipe lists empty.'),
  ('Vulnerability Scanning','Host scan recipe + target / both create=false','Recipe may be created or supplied by ID.\nDefault requested schedule: weekly Sunday; instance list empty.'),
  ('OCI Object Storage','Report bucket / create_report_bucket=false','When enabled: private, Standard, versioning Enabled, object events on.\nKMS key is an optional existing ID; no report producer is created.'),
  ('Notifications','Topic / create_topic=false','Existing topic ID may be supplied.\nNo subscription is declared.'),
  ('Events','Event rules / map empty','ONS / FAAS / OSS actions are operator inputs.\nFunctions and Streams must exist separately.'),
  ('Monitoring','Alarms / map empty','Queries, metric scope and destination IDs supplied per alarm.\nNo automatic alarm-to-topic wiring is inferred.'),
 ]
 for i,(icon,label,text) in enumerate(items):
  panel=d.group('optional',label,30+(i%3)*810,65+(i//3)*405,780,350,parent=reg,style_extra='verticalAlign=top;spacingTop=12;')
  d.icon(icon,100,125,parent=panel,size=52,label='',label_pos='top')
  d.text(text,25,220,730,95,parent=panel,size=13)
 footer(d,'DEFAULT RESULT: No resources. All create flags are false; event_rules={}, alarms={}, policy_statements=[].\nOptional access policy uses the home-region provider and defaults to tenancy-root placement. No IAM policy is created with empty statements.\nNo remediation Function, scan result export, report upload, notification delivery or security outcome is implemented or verified by this diagram.',1150)
 return d


def fsdr(title,index):
 d=header(title,index)
 icons=[]
 for i,role in enumerate(['Primary','Standby']):
  reg=d.group('region',role+' region / required explicit value (regions must differ)',20+i*1260,160,1200,850)
  comp=d.group('compartment',role+' compartment override → compartment_ocid → tenancy',20,60,1160,750,parent=reg)
  group=d.group('other','DR protection group / enabled by default',30,80,1100,230,parent=comp)
  pg=d.icon('Fullstack Disaster Recovery',130,115,parent=group,size=64,label=role+' DRPG',label_pos='left')
  d.text('Members input defaults empty.\nNo Compute/database/storage workloads are created.\n'+('PRIMARY role is established through peer association.' if i==0 else 'Association role=STANDBY; peer_id points to primary DRPG.'),280,65,790,120,parent=group,size=14)
  bucket=d.icon('OCI Object Storage',180,460,parent=comp,size=56,label=role+' log bucket\nEnabled / private / versioned',label_pos='bottom')
  d.connect(pg,bucket,kind='dashed',label='log_location reference',exit=(.5,1),entry=(.5,0),waypoints=[(reg.x+200,600)])
  d.text('Standard storage; versioning + object events enabled.\nExisting bucket names can be used if bucket creation is disabled.',350,420,760,95,parent=comp,size=13)
  if i==1:
   d.box('Optional DR plan / disabled by default\nenable_dr_plan=false; type defaults SWITCHOVER\nPlan belongs to standby DRPG; groups must be enabled.',30,590,1100,115,parent=comp,kind='optional')
  icons.append(pg)
 d.connect(icons[1],icons[0],kind='dashed',exit=(.5,0),entry=(.5,0),waypoints=[(1460,270),(200,270)],label='Standby → primary association only; not data replication')
 footer(d,'DEFAULT RESOURCE SHAPE: 2 DR protection groups + 2 regional log buckets, once required region/provider inputs are supplied.\nMember lists are empty and DR plan creation is disabled. Plan creation does not execute switchover/failover or configure workload replication.\nNo RTO/RPO or recoverability outcome is validated. Primary/standby placement is an input, not an approved live test scope.',1100)
 return d


def azure(title,index):
 d=header(title,index)
 reg=d.group('region','OCI primary / selected region',20,160,1400,880)
 comp=d.group('compartment','Target compartment / supplied or tenancy fallback',20,50,1360,800,parent=reg)
 vc=d.group('vcn','Primary VCN\n10.52.0.0/16 (default)',40,100,1280,490,parent=comp)
 sn=d.group('subnet','Application subnet\n10.52.10.0/24',100,110,720,240,parent=vc)
 d.text('Public IPs allowed; TCP 80/443 from explicit CIDR input.\nIngress CIDR defaults null and must be supplied.\nNo application Compute instance is created.',20,95,680,100,parent=sn,size=14)
 rt=d.icon('Route Table',1000,230,parent=vc,size=50,label='Default route → IGW',label_pos='top')
 igw=d.icon('Internet Gateway',1280,230,parent=vc,size=52,label='IGW',label_pos='top',border=True)
 d.connect(sn,rt,kind='plain',straight=True); d.connect(rt,igw,straight=True)
 d.icon('OCI Object Storage',280,690,parent=comp,size=52,label='Evidence bucket / default enabled\nStandard / versioning + object events',label_pos='top')
 d.icon('Notifications',1000,690,parent=comp,size=52,label='DR alert topic / default enabled\nNo alarm or subscription declared',label_pos='top')
 az=d.group('thirdparty','Azure standby / separate Bicep deployment',1530,160,950,880)
 net=d.box('VNet 10.72.0.0/16\nContainer App subnet 10.72.10.0/23, delegated to App environments\nUDR default → Internet; NSG inbound TCP 80/443',30,80,890,160,parent=az,kind='thirdparty_component')
 app=d.box('Managed Environment + Container App\nExternal ingress / target port 80 / insecure=false\nHello-world image default; replicas 1–2, CPU 0.5 / memory 1Gi\nApplication/data recovery is not configured by this sample.',30,340,890,180,parent=az,kind='thirdparty_component')
 logs=d.box('Log Analytics workspace\n30-day retention; App environment sends logs to workspace',30,650,890,110,parent=az,kind='thirdparty_component')
 d.connect(net,app,kind='plain',straight=True); d.connect(app,logs,kind='dashed',straight=True)
 footer(d,'CONTRACTS / DEFAULTS NEED REAL INPUTS\nDefault connectivity_mode=interconnect but FastConnect/ExpressRoute IDs are null. DNS contract enabled but endpoint inputs are null; ingress CIDR is null.\nThese contracts do not provision circuits, DRG, VPN, DNS records or a failover controller. RTO 30 min / RPO 15 min / TTL 30 sec are requested metadata.\nOCI and Azure are separate deployments; no workload/data replication, automatic DNS switch or tested DR outcome is created.',1120)
 return d


def main():
 parser=argparse.ArgumentParser(description=__doc__); parser.add_argument('--render',action='store_true'); args=parser.parse_args()
 for index,(slug,title,kind) in enumerate(ITEMS,11):
  d={'zero':zero,'health':health,'posture':posture,'fsdr':fsdr,'azure':azure}[kind](title,index)
  warnings=d.check(); print(slug,warnings,flush=True)
  if warnings: raise RuntimeError('Fix every layout warning before export')
  out=ROOT/'blueprints'/slug/'architecture/architecture.drawio'; d.save(str(out))
  if args.render and not d.render(str(out.with_suffix('.png')),scale=1.5): raise RuntimeError('draw.io export failed')
  with out.open('a') as stream: stream.write('\n')


if __name__=='__main__': main()
