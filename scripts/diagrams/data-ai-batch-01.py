#!/usr/bin/env python3
"""Five source-bounded data and AI overviews; no provisioning or service calls."""
import argparse
import importlib.util
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
def load(name):
 spec=importlib.util.spec_from_file_location(name,Path(__file__).with_name(name+'.py'))
 mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod);return mod
base=load('data-dr-batch-01');cloud=load('cloud-icons')
ITEMS=[
 ('data-platform/opensearch','OpenSearch | Optional private cluster and snapshot bucket','search'),
 ('data-platform/mysql-heatwave','MySQL HeatWave | Optional database, analytics and Lakehouse','mysql'),
 ('data-platform/oci-aws-mysql-heatwave-dr','OCI + AWS MySQL DR | Two cloud foundations and external DR steps','dr'),
 ('ai/genai-private','Generative AI | Optional private transport, storage and policy','genai'),
 ('ai/ai-services','AI Services | Optional projects, buckets and Vision endpoint','ai'),
]
def header(title,index):
 d=base.base.base.Diagram(toolkit=base.base.base.TOOLKIT,title=title)
 d.text(title,20,10,2460,45,size=25,bold=True)
 d.text(f'DATA / AI {index:02} / Official OCI Toolkit v24.2 / Source defaults, not operational evidence',20,65,2460,30,size=13)
 d.text('Lines: solid = declared association / configuration; dashed = external workflow or missing prerequisite. No line proves working traffic.',20,108,2460,30,size=13)
 return d

def database(title,index,search=False):
 d=header(title,index)
 reg=d.group('region','OCI / selected region',20,160,2460,900)
 vc=d.group('vcn','Optional VCN / create_private_network=false\n'+('10.85.0.0/16' if search else '10.83.0.0/16'),35,70,1630,740,parent=reg)
 sn=d.group('subnet','Private service subnet\n'+('10.85.10.0/24' if search else '10.83.10.0/24'),50,110,1530,435,parent=vc)
 db=d.icon('OpenSearch' if search else 'MySQL Database System',990 if search else 650,180,parent=sn,size=75,label='OpenSearch cluster / create_cluster=false' if search else 'MySQL DB System / create_db_system=false',label_pos='top')
 nsg=d.icon('NSG',150,180,parent=sn,size=50,label='Managed NSG',label_pos='top')
 d.text('Stateful client ingress\n'+('API TCP 9200 + Dashboards TCP 5601\nBoth approved CIDR sets default empty' if search else 'MySQL TCP 3306\nApproved CIDRs default 10.83.0.0/16'),45,270,680,110,parent=sn,size=15)
 d.text('Public IPs prohibited / empty security list attached\nNo IGW, NAT, SGW or custom route table declared',750,300,740,80,parent=sn,size=14)
 if search:
  text='Cluster sizing defaults (when enabled):\nOpenSearch 2.11.0 / 1 master / 1 data / 1 dashboard\nMaster + data: each 1 OCPU / 20 GB; data storage 50 GB\nDashboard: 1 OCPU / 8 GB; security settings default null'
 else:
  text='DB defaults (when enabled): MySQL.2 / 50 GB / HA=false\nBackup enabled / 7 days; credentials and AD require inputs\nOptional HeatWave cluster: 1 × HeatWave.512GB\ncreate_heatwave_cluster=false / Lakehouse acceleration=false'
 d.text(text,50,575,1530,135,parent=vc,size=16)
 services=d.group('osn','Optional storage and policy / managed outside VCN',1735,70,680,740,parent=reg)
 bucket=d.icon('OCI Object Storage',130,170,parent=services,size=65,label='Snapshot bucket' if search else 'Lakehouse bucket',label_pos='top')
 d.text(('create_snapshot_bucket=false' if search else 'create_lakehouse_bucket=false')+'\nPrivate / Standard / versioned / events enabled\nOptional existing KMS key; no key is created\nNo export, snapshot schedule or data load declared',30,270,620,150,parent=services,size=15)
 d.icon('Policies',110,535,parent=services,size=50,label='Optional IAM policy',label_pos='top')
 d.text('policy_statements=[] / no policy by default\nHome-region provider / policy compartment\ndefaults to tenancy root',30,610,620,90,parent=services,size=15)
 if not search:
  hw=d.icon('MySQL HeatWave',1230,180,parent=sn,size=65,label='HeatWave / optional',label_pos='top')
  d.connect(db,hw,label='DB System attachment',straight=True)
  d.connect(bucket,hw,kind='dashed',label='External Lakehouse object reads',exit=(0,.5),entry=(1,.5),waypoints=[(1720,400),(1720,520)])
 else:
  d.connect(db,bucket,kind='dashed',label='Snapshot registration / export: external',exit=(1,.5),entry=(0,.5),waypoints=[(1720,520),(1720,400)])
 d.connect(nsg,db,kind='plain',label='NSG attachment',straight=True)
 base.footer(d,('DEFAULT RESULT: No resources; all creation flags false and policy statements empty.\nCluster requires the created private network or existing VCN, subnet and NSG IDs. No mixed unused created network is allowed.\nNo client workloads, indexes, ingestion, automated snapshots or tested API/Dashboard access are delivered.' if search else 'DEFAULT RESULT: No resources; all creation flags false and policy statements empty.\nReuse a supplied subnet/NSGs or create the optional network; HeatWave can attach to a supplied DB System ID.\nBucket creation does not authorize Lakehouse reads.'))
 return d

def dr(title,index):
 d=header('OCI + AWS MySQL DR | Dedicated primary transport and separate optional VPN',index)
 reg=d.group('region','OCI primary / selected supported region and compartment',20,170,1200,1200)
 aws=d.group('thirdparty','AWS standby / separately deployed CloudFormation / selected region',1420,170,1200,1200)
 vc=d.group('vcn','Private primary VCN / 10.74.0.0/16',40,80,1120,400,parent=reg)
 sn=d.group('subnet','Private MySQL subnet / 10.74.10.0/24',40,90,760,240,parent=vc)
 db=d.icon('MySQL Database System',180,105,parent=sn,size=70,label='Optional MySQL DB System',label_pos='top')
 hw=d.icon('MySQL HeatWave',550,105,parent=sn,size=65,label='Optional HeatWave',label_pos='top')
 d.connect(db,hw,label='DB System attachment',straight=True)
 d.text('TCP 3306 from approved app CIDR; AWS CIDR when dedicated OR VPN enabled.\nNo public IPs. DB/HeatWave disabled by default. Seeding/channel setup is external.',25,170,710,60,parent=sn,size=13)
 rt=d.icon('Route Table',970,230,parent=vc,size=60,label='AWS prefix → DRG\nDedicated OR VPN flag',label_pos='top')
 d.connect(sn,rt,kind='plain',label='route_table_id',exit=(1,.5),entry=(0,.5),straight=True)
 drg=d.icon('DRG',600,600,parent=reg,size=85,label='DRG + VCN attachment\nCreated when dedicated OR VPN enabled',label_pos='top')
 d.connect(rt,drg,exit=(.5,1),entry=(.5,0),waypoints=[(1030,730),(620,730)])
 vpc=d.group('thirdparty','Private standby VPC / 10.84.0.0/16',40,80,1120,400,parent=aws)
 cloud.icon(d,'AWS::EC2::VPC',45,50,parent=vpc,size=45)
 for i,cidr in enumerate(['10.84.10.0/24','10.84.20.0/24']):
  d.group('thirdparty','AZ '+str(i+1)+' subnet / '+cidr,40+550*i,95,510,95,parent=vpc)
 rds=cloud.icon(d,'AWS::RDS::DBInstance',180,300,parent=vpc,size=70,label='Optional private RDS MySQL',label_pos='top')
 d.text('MySQL 8.0 / db.t4g.micro / 20 GB / MultiAZ=false\nEncrypted / 7-day backups / deletion protection / OCI-scoped TCP 3306\nTwo AZ subnets do not make the RDS instance multi-AZ.',340,250,735,110,parent=vpc,size=15)
 edge=cloud.icon(d,'AWS::DirectConnect::Connection',600,600,parent=aws,size=95,label='EXTERNAL AWS private connection\nManaged Interconnect or partner Direct Connect',label_pos='top')
 d.connect(drg,edge,kind='fastconnect',label='PRIMARY / FastConnect + AWS private connection\nExternal activation, gateway association and symmetric routes',straight=True,label_offset=(0,65))
 vpn=d.group('optional','',70,850,1060,110,parent=reg)
 d.icon('Customer Premises Equipment',65,65,parent=vpn,size=70,label='')
 d.text('Optional OCI CPE + static-route IPSec\nenable_ipsec_connectivity=false / actual AWS endpoint required',125,15,910,85,parent=vpn,size=17)
 peer=cloud.box(d,'AWS::EC2::VPNConnection','EXTERNAL AWS VPN edge / optional backup or alternative\nTunnel pairing, return route and preference policy are not created',70,850,1060,110,parent=aws,kind='optional',icon_size=65,text_size=17)
 d.connect(vpn,peer,kind='vpn',label='SEPARATE VPN / optional backup or alternative\nIndependent connector; not automatic failover',straight=True,label_offset=(0,60))
 d.connect(vpn,drg,kind='plain',label='ipsec drg_id',exit=(.5,0),entry=(.5,1),straight=True)
 d.icon('OCI Object Storage',200,1100,parent=reg,size=60,label='Lakehouse bucket / enabled\nPrivate / versioned / events',label_pos='top')
 d.icon('Notifications',1000,1100,parent=reg,size=60,label='Alert topic / enabled\nNo alarm or subscription',label_pos='top')
 logs=[]
 for i,(typ,label) in enumerate([('AWS::EC2::FlowLog','VPC flow log / ALL'),('AWS::Logs::LogGroup','Encrypted Log Group / 30 days'),('AWS::KMS::Key','KMS key / rotation')]):
  logs.append(cloud.icon(d,typ,200+400*i,1100,parent=aws,size=60,label=label,label_pos='top'))
 d.connect(logs[0],logs[1],label='Delivery',straight=True);d.connect(logs[2],logs[1],label='Encryption',straight=True)
 d.box('EXTERNAL DR OPERATIONS: no MySQL channel/seeding, AWS edge/return routes, DNS cutover or failover controller is created.\nSupply the activated circuit IDs, attach FastConnect to the DRG from this root, verify BGP and route preference, then test the application path.\nRTO/RPO/TTL are contract targets. The chosen managed or partner offering must support the selected connection locations.',20,1440,2600,140,kind='note')
 return d

def genai(title,index):
 d=header(title,index)
 reg=d.group('region','OCI / selected region and compartment',20,160,2460,900)
 net=d.group('other','Existing network / operator supplied; not created',35,80,1420,690,parent=reg)
 sn=d.group('other','Existing private-endpoint subnet / subnet_id=null',40,100,1340,470,parent=net)
 pe=d.box('Generative AI private endpoint\nenable_private_endpoint=false\nDNS prefix: genai\nExisting nsg_ids=[]',460,110,760,180,parent=sn)
 caller=d.box('Existing application / archive writer\nEXTERNAL / not created',35,130,320,130,parent=sn,kind='optional')
 d.connect(caller,pe,kind='dashed',label='External API client',straight=True)
 d.text('No VCN, subnet, NSG, security rule or DNS record is created.\nClient network, routing and model access remain external prerequisites.',40,340,1260,85,parent=sn,size=16)
 services=d.group('osn','Optional regional resources / independent creation flags',1530,80,880,690,parent=reg)
 archive=d.icon('OCI Object Storage',140,170,parent=services,size=65,label='Archive bucket / disabled',label_pos='top')
 d.text('create_archive_bucket=false\nPrivate / Standard (not Archive tier by default)\nVersioning + object events enabled\nOptional existing KMS key; no key created',280,100,550,160,parent=services,size=15)
 d.icon('Policies',140,445,parent=services,size=55,label='IAM access policy / optional',label_pos='top')
 d.text('policy_statements=[] / home provider\nPolicy compartment defaults to tenancy root\nNo group, dynamic group or model created',280,380,550,145,parent=services,size=15)
 d.connect(caller,archive,kind='dashed',label='Optional archive writes / external',exit=(.5,0),entry=(0,.5),waypoints=[(290,410),(1490,410)])
 base.footer(d,'DEFAULT RESULT: No resources; private endpoint and archive bucket flags false, policy statements empty.\nThe endpoint provides a private-transport configuration resource. No model deployment, dedicated AI cluster, inference application or archival pipeline is declared.\nThe bucket is an independent storage resource.')
 return d

def ai(title,index):
 d=header(title,index)
 reg=d.group('region','OCI / selected region and compartment / all service flags false by default',20,160,2460,900)
 services=d.group('osn','Optional AI service projects / control-plane containers',35,75,2390,270,parent=reg)
 projects=[]
 for i,(icon,label) in enumerate([('Document Understanding','Document project\nenable_document_project=false'),('OCI Language','Language project\nenable_language_project=false'),('OCI Vision','Vision project\nenable_vision_project=false')]):
  projects.append(d.icon(icon,260+780*i,140,parent=services,size=65,label=label,label_pos='top'))
 caller=d.box('EXTERNAL application / jobs / result writer (not created)',975,355,500,40,parent=reg,kind='optional')
 for i,project in enumerate(projects):
  d.connect(caller,project,kind='dashed',exit=(.5,0),entry=(.5,1),waypoints=[(1245,475-15*i),(315+780*i,475-15*i)])
 storage=d.group('optional','Input + output storage / create_buckets=false',35,405,1120,390,parent=reg,style_extra='verticalAlign=top;spacingTop=12;')
 inp=d.icon('OCI Object Storage',160,140,parent=storage,size=65,label='Input bucket',label_pos='top')
 out=d.icon('OCI Object Storage',780,140,parent=storage,size=65,label='Output bucket',label_pos='top')
 d.text('One for_each declaration expands to input + output when enabled.\nPrivate / Standard / versioned / object events enabled\nOptional existing KMS key; no processing or result writer created.',35,250,1050,100,parent=storage,size=15)
 net=d.group('other','Existing compatible subnet / not created',1235,405,1190,390,parent=reg)
 pe=d.box('Vision private endpoint\ncreate_vision_private_endpoint=false\nvision_private_endpoint_subnet_id=null',120,95,950,130,parent=net)
 d.connect(inp,caller,kind='dashed',label='External reads',exit=(.5,1),entry=(.4,1),waypoints=[(215,785),(1200,785),(1200,580),(1195,580)])
 d.connect(caller,out,kind='dashed',label='External result writes',exit=(.5,1),entry=(.5,1),waypoints=[(1245,800),(835,800)])
 d.connect(caller,pe,kind='dashed',label='Optional Vision private access',exit=(1,.5),entry=(.5,0),waypoints=[(1850,535)])
 d.text('No VCN, subnet, routing or NSG is created.\nNo private endpoints for Document or Language declared.',35,270,1120,70,parent=net,size=15)
 base.footer(d,'DEFAULT RESULT: No resources; project, bucket and Vision endpoint flags false, policy statements empty.\nOptional IAM access policy uses the home provider; its compartment defaults to tenancy root. Existing KMS key and network identifiers are references only.\nNo model, OCR/inference job, event rule, function, ingestion worker or application is declared. The diagram shows configuration groups, not an executed data pipeline.')
 return d

def main():
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--render',action='store_true');args=parser.parse_args()
 for index,(slug,title,kind) in enumerate(ITEMS,21):
  d={'search':lambda t,i:database(t,i,True),'mysql':database,'dr':dr,'genai':genai,'ai':ai}[kind](title,index)
  warnings=d.check();print(slug,warnings,flush=True)
  if warnings:raise RuntimeError('Fix layout warnings before export')
  path=ROOT/'blueprints'/slug/'architecture/architecture.drawio';d.save(str(path))
  if args.render and not d.render(str(path.with_suffix('.png')),scale=1.5):raise RuntimeError('draw.io export failed')
  with path.open('a') as f:f.write('\n')
if __name__=='__main__':main()
