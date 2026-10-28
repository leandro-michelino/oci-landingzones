#!/usr/bin/env python3
"""Catalog continuation: AWS DR and four data-platform overviews; no cloud calls."""
import argparse
import importlib.util
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
def load(name):
 spec=importlib.util.spec_from_file_location(name,Path(__file__).with_name(name+'.py'))
 mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod);return mod
base=load('compliance-dr-batch-01');cloud=load('cloud-icons')
ITEMS=[
 ('disaster-recovery/aws-oci-cross-cloud-dr','AWS + OCI DR | Separate foundations and recovery contracts','aws'),
 ('data-platform/autonomous-database','Autonomous Database | Optional private network and database','adb'),
 ('data-platform/private-data-platform','Private data platform | Storage and Streaming endpoints','private'),
 ('data-platform/postgresql','PostgreSQL | Optional private network and DB system','postgres'),
 ('data-platform/apex-adw','APEX / ORDS | Existing database and optional ingress','apex'),
]

def header(title,index):
 d=base.base.Diagram(toolkit=base.base.TOOLKIT,title=title)
 d.text(title,20,10,2460,45,size=25,bold=True)
 d.text(f'DATA / DR {index:02} / Official OCI Toolkit v24.2 / Source defaults, not operational evidence',20,65,2460,30,size=13)
 return d

def footer(d,text):
 base.footer(d,text,1150)

def aws(title,index):
 d=header(title,index)
 reg=d.group('region','OCI primary / selected region',20,160,1180,900)
 comp=d.group('compartment','Selected compartment or tenancy fallback',20,55,1140,800,parent=reg)
 vc=d.group('vcn','Primary VCN\n10.52.0.0/16',30,80,1080,480,parent=comp)
 sn=d.group('subnet','Application subnet\n10.52.10.0/24',60,110,600,240,parent=vc)
 d.text('Public IPs permitted; TCP 80/443 from explicit source CIDR.\nCIDR input defaults null. No OCI Compute workload is created.\nSecurity list allows unrestricted egress.',20,100,560,105,parent=sn,size=14)
 rt=d.icon('Route Table',820,230,parent=vc,label='Default → IGW',label_pos='top',size=50)
 igw=d.icon('Internet Gateway',1080,230,parent=vc,label='IGW',label_pos='top',size=50,border=True)
 d.connect(sn,rt,kind='plain',straight=True);d.connect(rt,igw,straight=True)
 d.icon('OCI Object Storage',250,690,parent=comp,size=52,label='DR evidence bucket / enabled\nStandard / versioned / object events',label_pos='top')
 d.icon('Notifications',850,690,parent=comp,size=52,label='Alert topic / enabled\nNo subscription or alarm declared',label_pos='top')
 az=d.group('thirdparty','AWS standby / separately deployed CloudFormation stack',1300,160,1180,900)
 vpc=d.group('thirdparty','Standby VPC / 10.82.0.0/16',30,70,1120,530,parent=az)
 cloud.icon(d,'AWS::EC2::VPC',75,85,parent=vpc,size=52)
 subnet=d.group('thirdparty','Standby subnet / 10.82.10.0/24 / first AZ',160,65,700,365,parent=vpc)
 ec2=cloud.icon(d,'AWS::EC2::Instance',100,150,parent=subnet,size=58,label='EC2 / t3.micro',label_pos='top')
 d.text('Launch template / Amazon Linux 2023 / IMDSv2 required\nEncrypted gp3 root volume / 8 GiB\nInstance interface requests public IP; EIP + association\nUser data installs Python and serves a demo page on HTTP 80.\nSG ingress 80/443; only 443 egress; CIDR defaults 10.0.0.0/8.',200,75,470,200,parent=subnet,size=13)
 gw=cloud.icon(d,'AWS::EC2::InternetGateway',1010,235,parent=vpc,size=50,label='IGW + attachment\nRT + default route + association',label_pos='top')
 d.connect(subnet,gw,kind='plain',straight=True)
 d.connect(sn,subnet,kind='dashed',label='Cross-cloud connectivity intent / external interconnect; IDs only',exit=(.5,1),entry=(0,.5),waypoints=[(430,810),(1235,810),(1235,477.5)])
 d.text('Subnet auto public IP assignment is false; launch-template interface overrides it.\nDefault restricted egress may prevent package/SSM access. No TLS server is bootstrapped.',30,455,1060,55,parent=vpc,size=13)
 support=[]
 for i,(typ,label) in enumerate([('AWS::IAM::Role','EC2 SSM role + instance profile'),('AWS::EC2::FlowLog','VPC flow log / ALL traffic'),('AWS::Logs::LogGroup','30-day Log Group + KMS key + log role')]):
  support.append(cloud.icon(d,typ,140+350*i,735,parent=az,size=50,label=label,label_pos='top'))
 d.connect(support[1],support[2],label='Flow-log delivery',straight=True)
 d.connect(support[0],ec2,label='SSM role / instance profile attachment',exit=(0,.5),entry=(0,.5),waypoints=[(1310,895),(1310,445)])
 footer(d,'SOURCE DEFAULTS REQUIRE INPUTS: OCI network/bucket/topic enabled, ingress CIDR null; example tfvars disables cloud creation.\nInterconnect IDs and DNS endpoints are null. Contracts store connectivity, DNS TTL 30 sec, RTO 30 min / RPO 15 min and quarterly drill intent.\nNo circuits, DNS records, replication, health checks or failover controller are created. AWS demo HTTP service is not a recovered application.\nThe resource-detail pages enumerate every OCI/AWS declaration, including IAM, associations, EIP and launch-template resources.')
 return d


def database(title,index,postgres=False):
 d=header(title,index);prefix='PostgreSQL' if postgres else 'Autonomous Database'
 net='10.81' if postgres else '10.82';port='5432' if postgres else '1522'
 reg=d.group('region','OCI / selected region',20,160,2460,900)
 comp=d.group('compartment','Selected compartment / tenancy fallback',20,55,2420,800,parent=reg)
 vc=d.group('vcn','Optional VCN / create_private_network=false\n'+net+'.0.0/16',40,80,1720,650,parent=comp)
 sn=d.group('subnet','Private database subnet\n'+net+'.10.0/24',80,110,1560,420,parent=vc)
 db=d.icon('OCI Database with PostgreSQL' if postgres else 'Oracle Autonomous Database',1160,190,parent=sn,size=80,label=prefix+' / disabled by default',label_pos='top')
 nsg=d.box('NSG / explicit client ingress',90,155,340,70,parent=sn)
 d.connect(nsg,db,kind='plain',label='TCP '+port+' / stateful rules',straight=True)
 d.text('Ingress-empty security list attached. Public IPs prohibited.\nNo IGW, NAT, SGW or custom route table is created.\nClient CIDRs: '+('10.81.0.0/16 default' if postgres else 'empty by default; no ingress until supplied')+'.',40,310,1460,80,parent=sn,size=14)
 d.text('Reuse an existing subnet/NSG set through input IDs, or create the optional network.\nSubnet and NSGs are selected independently; review that they belong to the intended VCN.',50,570,1610,60,parent=vc,size=14)
 panel=d.group('other','Database configuration / only when explicitly enabled',1810,80,570,650,parent=comp)
 if postgres:
  lines='enable_db_system=false\nPostgreSQL version input: 14\nE5 Flex / 1 instance / 2 OCPU / 32 GiB\nRegionally durable optimized storage\nReader endpoint disabled\nManagement policy enabled\nCustom backup policy and source default null\nCredentials: plain text or existing Vault secret\nConnection details are a read-only data lookup.'
 else:
  lines='enable_autonomous_database=false\nDefault workload OLTP; DW is operator choice\n2 ECPU / 1 TB / autoscaling enabled\nmTLS required / paid tier / License Included\nAdmin password defaults null\nExisting KMS key ID optional\nManual backup disabled by default\nOptional backup retention / long-term settings'
 d.text(lines,25,80,520,490,parent=panel,size=16)
 if postgres:
  footer(d,'DEFAULT RESULT: No resources; DB system and network flags are false, policy_statements=[].\nOptional IAM policy uses home-region provider; policy compartment defaults to tenancy root. No Vault/secret is created.\nRequested size/version/storage settings are source defaults, not quota, availability or compatibility validation. No PostgreSQL traffic or restore was tested.')
 else:
  footer(d,'DEFAULT RESULT: No resources; database, private network and manual backup flags are false.\nThe private topology shown requires an existing subnet or the optional network. Enabling only the database does not establish a private endpoint.\nOnly one workload is selected per database (OLTP default, or DW); no simultaneous ATP/ADW pair, replicas, Vault, clients or access path is created.')
 return d


def private(title,index):
 d=header(title,index)
 reg=d.group('region','OCI / selected region and compartment (tenancy fallback)',20,160,2460,900)
 vc=d.group('vcn','Pinned private network / 10.20.0.0/16\nNetworking c07231c → spoke-vcn v0.2.0',30,70,1660,740,parent=reg)
 for i,(name,cidr) in enumerate([('App','10.20.1.0/24'),('Data','10.20.2.0/24')]):
  s=d.group('subnet',name+' subnet\n'+cidr,40,100+180*i,600,135,parent=vc)
  d.text('Private / no workload instances created',20,80,560,35,parent=s,size=13)
 ep=d.group('subnet','Endpoints subnet\n10.20.3.0/24',760,100,840,430,parent=vc)
 os=d.box('Object Storage private endpoint\nTarget: data bucket / prefix=data\nManaged NSG / TCP 443 / approved CIDRs=[]',30,80,780,120,parent=ep)
 stream=d.icon('OCI Streaming',100,320,parent=ep,size=60,label='Stream pool private endpoint',label_pos='top')
 d.text('Managed NSG / REST 443 + Kafka 9092\nApproved client CIDRs=[]\nExisting subnet/NSGs may override defaults.',230,330,570,85,parent=ep,size=14)
 rt=d.icon('Route Table',900,630,parent=vc,size=48,label='Private RT / OSN label → SGW',label_pos='top')
 sg=d.icon('Service Gateway',1660,630,parent=vc,size=50,label='SGW',label_pos='top',border=True)
 d.connect(rt,sg,straight=True)
 d.text('Baseline: no ingress; egress to 10.20.0.0/16 + HTTPS to regional OSN.\nNo IGW. NAT disabled; enabling a NAT alone does not add a default internet route.',30,570,760,120,parent=vc,size=14)
 services=d.group('osn','Managed regional services / logical placement',1770,70,650,740,parent=reg)
 bucket=d.icon('OCI Object Storage',150,155,parent=services,size=60,label='Data bucket / enabled',label_pos='top')
 d.text('Private / Standard / versioning + events on\nAuto tiering disabled / Vault key by default',30,245,590,65,parent=services,size=14)
 pool=d.icon('OCI Streaming',150,420,parent=services,size=60,label='Stream pool + ingest stream / enabled',label_pos='top')
 d.text('1 partition / 24-hour retention default\nVault key used by default; existing pool supported',30,520,590,65,parent=services,size=14)
 d.connect(os,bucket,kind='dashed',label='Access target',exit=(1,.5),entry=(0,.5),waypoints=[(1760,465),(1760,385)])
 # Private endpoint settings are configuration links, not verified packets.
 d.connect(stream,pool,kind='dashed',exit=(1,.5),entry=(0,.5),waypoints=[(1740,650),(1740,650)])
 footer(d,'ENABLED BY DEFAULT: pinned network, Vault + default key, private data bucket, Object Storage private endpoint, Stream pool and ingest stream.\nVault/key are KMS configuration dependencies for bucket and pool; existing key IDs may override them. No app, database or ingestion worker is created.\nEndpoint ingress sets are empty by default; service-gateway access and service private endpoints are distinct mechanisms. No endpoint traffic is verified.')
 # Vault is placed in a separate explicit configuration band, outside the VCN.
 d.icon('Vault',350,1100,size=48,label='Vault + default key / v0.2.0 / enabled',label_pos='right')
 return d


def apex(title,index):
 d=header(title,index)
 reg=d.group('region','OCI / supplied compartment → existing ADB compartment → tenancy',20,160,2460,900)
 net=d.group('other','Existing VCN / subnets / NSGs / routing supplied by operator',30,70,2390,500,parent=reg)
 lb=d.group('optional','Load balancer / enable_load_balancer=false',40,80,1080,350,parent=net,style_extra='verticalAlign=top;spacingTop=12;')
 lbi=d.icon('Load Balancer',150,160,parent=lb,size=70,label='Optional private flexible LB',label_pos='bottom')
 d.text('Create new (default) or use existing LB ID\nHTTPS listener 443 requires supplied certificate\nBackend set / ROUND_ROBIN; per-IP backend records\nHTTPS health check /ords/ / expected 200\nBackend TLS enabled; verify_peer=false default',280,80,760,230,parent=lb,size=15)
 adb=d.group('other','Existing database / not created by this blueprint',1300,80,1050,350,parent=net)
 db=d.icon('Oracle Autonomous Database',140,160,parent=adb,size=75,label='Existing ADB / APEX + ORDS',label_pos='bottom')
 d.text('ADB OCID optional / data lookup only\nPrivate IP from lookup or explicit override\nExplicit backend IPs can also be supplied\nAPEX/ORDS URLs may be read or overridden\nNo workspace or schema bootstrap is executed.',300,80,710,230,parent=adb,size=15)
 d.connect(lbi,db,kind='dashed',label='Configured backend / 443',exit=(.5,0),entry=(.5,0),waypoints=[(240,365),(1490,365)])
 sec=d.group('optional','Admin/bootstrap secret / enable_admin_secret=false',40,640,1080,150,parent=reg,style_extra='verticalAlign=top;spacingTop=12;')
 d.icon('Vault',90,85,parent=sec,size=45,label='',label_pos='top')
 d.text('Existing Vault + key required for optional secret creation.\nAlternatively reuse admin_secret_id. No Vault/key is created.',200,45,840,75,parent=sec,size=14)
 d.text('FQDN is an input for URL output only; no DNS record is created.\nExisting network must permit LB-to-ORDS traffic. External certificates\nand endpoint reachability remain operator prerequisites.',1330,640,1040,145,parent=reg,size=16)
 footer(d,'DEFAULT RESULT: No created resources; load balancer and admin secret flags are false and ADB ID is null.\nThis blueprint adds ingress and secret support to an existing ADB. It does not create ADW/ATP, APEX workspace, users or application deployment.\nListener, backend set, backends and secret are explicitly enumerated in resource-detail pages. No health probe, TLS session or APEX login was tested.')
 return d


def main():
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--render',action='store_true');args=parser.parse_args()
 for index,(slug,title,kind) in enumerate(ITEMS,16):
  d={'aws':aws,'adb':lambda t,i:database(t,i),'postgres':lambda t,i:database(t,i,True),'private':private,'apex':apex}[kind](title,index)
  warnings=d.check();print(slug,warnings,flush=True)
  if warnings: raise RuntimeError('Fix layout warnings before export')
  path=ROOT/'blueprints'/slug/'architecture/architecture.drawio';d.save(str(path))
  if args.render and not d.render(str(path.with_suffix('.png')),scale=1.5):raise RuntimeError('draw.io export failed')
  with path.open('a') as f:f.write('\n')
if __name__=='__main__':main()
