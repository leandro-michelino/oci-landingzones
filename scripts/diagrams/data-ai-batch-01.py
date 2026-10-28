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
 return d

def database(title,index,search=False):
 d=header(title,index)
 reg=d.group('region','OCI / selected region',20,160,2460,900)
 vc=d.group('vcn','Optional VCN / create_private_network=false\n'+('10.85.0.0/16' if search else '10.83.0.0/16'),35,70,1630,740,parent=reg)
 sn=d.group('subnet','Private service subnet\n'+('10.85.10.0/24' if search else '10.83.10.0/24'),50,110,1530,435,parent=vc)
 db=d.icon('OpenSearch' if search else 'MySQL Database System',990,180,parent=sn,size=75,label='OpenSearch cluster / create_cluster=false' if search else 'MySQL DB System / create_db_system=false',label_pos='top')
 d.icon('NSG',150,180,parent=sn,size=50,label='Managed NSG',label_pos='top')
 d.text('Stateful client ingress\n'+('API TCP 9200 + Dashboards TCP 5601\nBoth approved CIDR sets default empty' if search else 'MySQL TCP 3306\nApproved CIDRs default 10.83.0.0/16'),45,270,680,110,parent=sn,size=15)
 d.text('Public IPs prohibited / empty security list attached\nNo IGW, NAT, SGW or custom route table declared',750,300,740,80,parent=sn,size=14)
 if search:
  text='Cluster sizing defaults (when enabled):\nOpenSearch 2.11.0 / 1 master / 1 data / 1 dashboard\nMaster + data: each 1 OCPU / 20 GB; data storage 50 GB\nDashboard: 1 OCPU / 8 GB; security settings default null'
 else:
  text='DB defaults (when enabled): MySQL.2 / 50 GB / HA=false\nBackup enabled / 7 days; credentials and AD require inputs\nOptional HeatWave cluster: 1 × HeatWave.512GB\ncreate_heatwave_cluster=false / Lakehouse acceleration=false'
 d.text(text,50,575,1530,135,parent=vc,size=16)
 services=d.group('osn','Optional storage and policy / managed outside VCN',1735,70,680,740,parent=reg)
 d.icon('OCI Object Storage',130,170,parent=services,size=65,label='Snapshot bucket' if search else 'Lakehouse bucket',label_pos='top')
 d.text(('create_snapshot_bucket=false' if search else 'create_lakehouse_bucket=false')+'\nPrivate / Standard / versioned / events enabled\nOptional existing KMS key; no key is created\nNo export, snapshot schedule or data load declared',30,270,620,150,parent=services,size=15)
 d.icon('Policies',110,535,parent=services,size=50,label='Optional IAM policy',label_pos='top')
 d.text('policy_statements=[] / no policy by default\nHome-region provider / policy compartment\ndefaults to tenancy root',30,610,620,90,parent=services,size=15)
 if not search:
  d.icon('MySQL HeatWave',850,850,parent=reg,size=45,label='HeatWave attaches to created or supplied DB System; no analytics job executed',label_pos='right')
 base.footer(d,('DEFAULT RESULT: No resources; all creation flags false and policy statements empty.\nCluster requires the created private network or existing VCN, subnet and NSG IDs. No mixed unused created network is allowed.\nNo client workloads, indexes, ingestion, automated snapshots or tested API/Dashboard access are delivered.' if search else 'DEFAULT RESULT: No resources; all creation flags false and policy statements empty.\nReuse a supplied subnet/NSGs or create the optional network; HeatWave can attach to a supplied DB System ID.\nBucket creation does not authorize Lakehouse reads. No schemas, data loads, queries, backup restore or database connection was executed.'))
 return d

def dr(title,index):
 d=header(title,index)
 reg=d.group('region','OCI primary / selected region and compartment',20,160,1180,900)
 vc=d.group('vcn','Primary VCN / enable_oci_primary_network=true\n10.74.0.0/16',30,70,1120,540,parent=reg)
 sn=d.group('subnet','Private DB subnet\n10.74.10.0/24',35,105,790,320,parent=vc)
 d.icon('MySQL Database System',160,160,parent=sn,size=60,label='DB System / disabled',label_pos='top')
 d.icon('MySQL HeatWave',550,160,parent=sn,size=60,label='HeatWave / disabled',label_pos='top')
 d.text('DB defaults: E4.1.8GB / 100 GB / HA / 7-day backups\nSL: app CIDR 3306; AWS CIDR only with IPSec; all egress',30,240,730,65,parent=sn,size=13)
 d.icon('Route Table',970,270,parent=vc,size=45,label='AWS CIDR → DRG\nonly with IPSec',label_pos='top')
 d.icon('DRG',1120,460,parent=vc,size=50,label='Optional DRG + attachment',label_pos='top',border=True)
 d.text('Optional CPE + static-route IPSec: enable_ipsec_connectivity=false\nRequires AWS VPN public IP; no BGP or tunnel configuration created.',30,465,1010,65,parent=vc,size=13)
 d.icon('OCI Object Storage',200,740,parent=reg,size=52,label='Lakehouse bucket / enabled\nPrivate / Standard / versioned / events',label_pos='top')
 d.icon('Notifications',850,740,parent=reg,size=52,label='Alert topic / enabled\nNo alarm or subscription declared',label_pos='top')
 aws=d.group('thirdparty','AWS secondary / separately deployed CloudFormation stack',1300,160,1180,900)
 vpc=d.group('thirdparty','Standby VPC / 10.84.0.0/16',30,70,1120,540,parent=aws)
 cloud.icon(d,'AWS::EC2::VPC',80,90,parent=vpc,size=48)
 for i,cidr in enumerate(['10.84.10.0/24','10.84.20.0/24']):
  subnet=d.group('thirdparty','Subnet '+str(i+1)+' / AZ '+str(i+1)+'\n'+cidr,40+545*i,145,505,125,parent=vpc)
  d.text('No automatic public IP assignment',20,75,465,35,parent=subnet,size=13)
 cloud.icon(d,'AWS::RDS::DBInstance',140,365,parent=vpc,size=60,label='Optional MySQL RDS',label_pos='top')
 d.text('CreateRdsStandby=true / MySQL 8.0 / db.t4g.micro / 20 GB\nPrivate / MultiAZ=false / encrypted / 7-day backups\nIAM DB authentication / deletion protection / Performance Insights\nDB subnet group uses both subnets; SG allows OCI CIDR on 3306',300,315,780,140,parent=vpc,size=14)
 d.text('Route table + 2 subnet associations; no AWS VPN edge or OCI route.\nTwo AZ subnets do not make the single-AZ RDS instance multi-AZ.',30,470,1060,60,parent=vpc,size=13)
 for i,(typ,label) in enumerate([('AWS::EC2::FlowLog','VPC flow log / ALL'),('AWS::Logs::LogGroup','30-day encrypted Log Group'),('AWS::KMS::Key','KMS key / rotation on')]):
  cloud.icon(d,typ,145+370*i,750,parent=aws,size=48,label=label,label_pos='top')
 d.text('IAM flow-log role and inline write policy; KMS also used for Performance Insights.',30,820,1120,45,parent=aws,size=13)
 base.footer(d,'REQUIRED INPUTS: default OCI network/bucket/topic flags are true, but complete DR contracts require both database endpoints (null by default).\nFive terraform_data contracts record network, connectivity, replication, DNS and runbook intent. RTO 30 min / RPO 10 min / DNS TTL 30 sec are targets only.\nAWS VPN edge/routes, MySQL seeding/replication and DNS records/cutover remain external steps. No operational cross-cloud path or failover is created or tested.\nResource-detail pages enumerate every OCI/AWS declaration, including security, IAM, subnet group, associations and conditional resources.')
 return d

def genai(title,index):
 d=header(title,index)
 reg=d.group('region','OCI / selected region and compartment',20,160,2460,900)
 net=d.group('other','Existing network / operator supplied; not created',35,80,1420,690,parent=reg)
 sn=d.group('other','Existing private-endpoint subnet / subnet_id=null',40,100,1340,470,parent=net)
 d.box('Generative AI private endpoint\nenable_private_endpoint=false\nDNS prefix: genai\nExisting nsg_ids=[]',240,110,850,180,parent=sn)
 d.text('No VCN, subnet, NSG, security rule or DNS record is created.\nClient network, routing and model access remain external prerequisites.',40,340,1260,85,parent=sn,size=16)
 services=d.group('osn','Optional regional resources / independent creation flags',1530,80,880,690,parent=reg)
 d.icon('OCI Object Storage',140,170,parent=services,size=65,label='Archive bucket / disabled',label_pos='top')
 d.text('create_archive_bucket=false\nPrivate / Standard (not Archive tier by default)\nVersioning + object events enabled\nOptional existing KMS key; no key created',280,100,550,160,parent=services,size=15)
 d.icon('Policies',140,445,parent=services,size=55,label='IAM access policy / optional',label_pos='top')
 d.text('policy_statements=[] / home provider\nPolicy compartment defaults to tenancy root\nNo group, dynamic group or model created',280,380,550,145,parent=services,size=15)
 base.footer(d,'DEFAULT RESULT: No resources; private endpoint and archive bucket flags false, policy statements empty.\nThe endpoint provides a private-transport configuration resource. No model deployment, dedicated AI cluster, inference application or archival pipeline is declared.\nNo inference, model availability, private DNS resolution, endpoint traffic or data-residency behavior was verified. The bucket is an independent storage resource.')
 return d

def ai(title,index):
 d=header(title,index)
 reg=d.group('region','OCI / selected region and compartment / all service flags false by default',20,160,2460,900)
 services=d.group('osn','Optional AI service projects / control-plane containers',35,75,2390,270,parent=reg)
 for i,(icon,label) in enumerate([('Document Understanding','Document project\nenable_document_project=false'),('OCI Language','Language project\nenable_language_project=false'),('OCI Vision','Vision project\nenable_vision_project=false')]):
  d.icon(icon,260+780*i,140,parent=services,size=65,label=label,label_pos='top')
 storage=d.group('optional','Input + output storage / create_buckets=false',35,405,1120,390,parent=reg,style_extra='verticalAlign=top;spacingTop=12;')
 d.icon('OCI Object Storage',160,140,parent=storage,size=65,label='Input bucket',label_pos='top')
 d.icon('OCI Object Storage',780,140,parent=storage,size=65,label='Output bucket',label_pos='top')
 d.text('One for_each declaration expands to input + output when enabled.\nPrivate / Standard / versioned / object events enabled\nOptional existing KMS key; no processing or result writer created.',35,250,1050,100,parent=storage,size=15)
 net=d.group('other','Existing compatible subnet / not created',1235,405,1190,390,parent=reg)
 d.box('Vision private endpoint\ncreate_vision_private_endpoint=false\nvision_private_endpoint_subnet_id=null',120,95,950,130,parent=net)
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
