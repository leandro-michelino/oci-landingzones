#!/usr/bin/env python3
"""Source-bounded CDN, Redis, NoSQL, MongoDB API and Digital Assistant views."""
import argparse, importlib.util
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
def load(name):
 s=importlib.util.spec_from_file_location(name,Path(__file__).with_name(name+'.py'));m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
base=load('extensions-batch-03')
ITEMS=[
 ('extensions/cdn-static-assets','CDN static assets | Optional Cloudflare edge and private OCI origin','cdn'),
 ('extensions/redis-cache','Redis Cache | Optional cluster, independent alarms and supplied network','redis'),
 ('data-platform/nosql','NoSQL | Regional managed tables and a separate optional application network','nosql'),
 ('data-platform/mongodb-api','MongoDB API | Optional Autonomous Database and private network bindings','mongo'),
 ('extensions/digital-assistant','Digital Assistant | Optional service, endpoint and explicit attachment','oda'),
]
def frame(title,index):return base.frame(title,index,True)
def finish(d,text):return base.finish(d,text,True)
def box(d,r,text,x,y,w=800,h=130):return d.box(text,x,y,w,h,parent=r)
def cdn(title,index):
 d=base.base.base.network.Diagram(toolkit=base.base.base.network.TOOLKIT,title=title)
 d.text(title,20,10,2940,45,size=25,bold=True)
 d.text('Official OCI Toolkit v24.2 / Named Cloudflare resources where no exact native glyph is available / Source configuration only',20,65,2940,30,size=13)
 d.text('Plain: ID/config association. Solid arrow: configured request intent. Dashed: external prerequisite. No line proves working traffic.',20,108,2940,30,size=13)
 cf=d.group('thirdparty','Cloudflare / supplied account and zone; independently enabled resources',20,160,1400,1120)
 r=d.group('region','OCI / selected region and compartment; tenancy fallback requires review',1560,160,1400,1120)
 route=box(d,cf,'Optional Worker route / create_cloudflare_worker_proxy=false\nZone + supplied pattern, or hostname + smoke path wildcard\nBinds the created script name',100,130,1200)
 worker=box(d,cf,'Optional Workers script / same creation flag\nGET + HEAD only / fixed OCI_PAR_URL fetch on cache miss\nCache API key: origin + pathname; query is ignored\nSecret binding: explicit upstream URL or selected created PAR',100,425,1200,150)
 d.connect(route,worker,kind='plain',label='script_name association / matched requests use script',exit=(.5,1),entry=(.5,0),straight=True)
 dns=box(d,cf,'Optional DNS record + two independent rulesets\ncreate_cloudflare_dns_record / cache_ruleset / origin_ruleset=false\nProxied CNAME; cache rule defaults to /public/\nOrigin rule changes host + SNI, not authorization or URL path',100,830,1200,155)
 bucket=d.icon('OCI Object Storage',700,500,parent=r,size=85,label='Optional private Standard bucket / create_asset_bucket=false\nVersioning Enabled / object events enabled\nNamespace read is unconditional, even with creation disabled',label_pos='top')
 objects=box(d,r,'Optional objects + lifecycle policy\ncreate_sample_objects=false / sample map + four defaults\ncreate_lifecycle_policy=false AND nonempty rules\nSelected bucket: created bucket or supplied existing name',100,130,1200)
 d.connect(objects,bucket,kind='plain',label='namespace / selected bucket / explicit object names',exit=(.5,1),entry=(.5,0),straight=True)
 par=box(d,r,'Optional preauthenticated requests / preauth_requests={}\nAccess type, scope, object and expiry are supplied\nA PAR is authorization material, not a forwarding service\nNo public bucket access is enabled',100,830,1200,155)
 d.connect(par,bucket,kind='plain',label='PAR grant scope: bucket / optional object',exit=(1,.5),entry=(1,.5),waypoints=[(2940,1067.5),(2940,660)],label_offset=(-100,0))
 d.connect(worker,bucket,label='Cache miss: fetch fixed OCI_PAR_URL / only when configured',exit=(1,.5),entry=(0,.5),straight=True)
 d.text('OCI DNS CNAME / create_dns_cname=false: existing zone + explicit target hostname.\nIAM policy / statements=[]: home provider, policy compartment falls back to tenancy.\nCloudflare zone/account, KMS key and DNS zones are references, not created resources.\nOrigin rules alone cannot read a private bucket. PAR broker sample is not deployed.',100,660,1200,130,parent=r,size=16)
 d.text('Worker caches successful responses; TTL default 300 s.\nNo path append to the fixed upstream URL. Review query-insensitive\ncache keys and PAR scope before using personalized content.\nDNS, cache and origin rules can be enabled independently.',100,650,1200,130,parent=cf,size=16)
 return finish(d,'DEFAULT RESULT: No created cloud resources; all create flags false, maps and IAM statements empty. The namespace data lookup still runs.\nSix OCI and five Cloudflare resource declarations are enumerated in native detail pages. DNS records do not automatically bind each other.\nThe explicit Worker-to-bucket arrow is configured fetch intent, not a claim of successful authorization, origin connectivity or cache delivery.')
def redis(title,index):
 d,r=frame(title,index)
 cluster=box(d,r,'Optional OCI Redis cluster / create_cluster=false\nSource defaults: software 7.0.5 / two nodes / 2 GB per node\nOptional shard_count, cluster_mode, configuration-set ID and backup ID\nVersion and capacity availability require service/region review',100,170,1200,165)
 network=box(d,r,'Existing network inputs / subnet_id=null / nsg_ids=[]\nNo VCN, subnet, NSG, route, DNS or gateway created',1660,170,1180,165)
 d.connect(cluster,network,kind='plain',label='subnet_id / nsg_ids when creating the cluster',straight=True)
 alarms=d.icon('Alarms',650,650,parent=r,size=70,label='Independent optional alarms / alarms={}\nNamespace, query, severity and destinations supplied\nNot automatically bound to the created cluster',label_pos='top')
 targets=box(d,r,'Existing notification destination IDs per alarm\nNo destination topic or subscription is created\nMetric compartment: per-alarm override or target compartment',1660,580,1180,140)
 d.connect(alarms,targets,kind='plain',label='destinations[] / supplied identifiers',straight=True)
 d.icon('Policies',650,960,parent=r,size=55,label='Optional IAM policy / statements=[]\nHome provider / policy compartment fallback: tenancy',label_pos='top')
 d.text('redis_cluster_id is the output fallback when creation is disabled; no existing cluster is changed.\nvault_secret_id is output metadata only; it is not bound to the cluster or a workload.\nPrimary/discovery FQDN outputs come only from a created cluster. No application is deployed.\nNo exact Redis resource glyph is mapped; the named resource box avoids a substitute icon.',1660,850,1180,170,parent=r,size=17)
 return finish(d,'DEFAULT RESULT: No resources; cluster creation false, alarms map empty and IAM statements empty. Three resource declarations.\nAlarms are independent of the cluster flag and use operator-supplied metric queries; no automatic cluster metrics filter or notification recipient is inferred.\nLines show supplied configuration only. No authentication, Vault secret retrieval, cache client, route or application connection is created.')
def nosql(title,index):
 d,r=frame(title,index)
 v=d.group('vcn','Optional application VCN / enable_app_network=true / 10.84.0.0/16',60,80,1320,920,parent=r)
 subnet=d.group('subnet','Application subnet / 10.84.10.0/24 / public IP assignment permitted',40,150,1240,235,parent=v)
 rt=d.icon('Route Table',330,570,parent=v,size=60,label='Explicit app route table\n0.0.0.0/0 to created IGW',label_pos='top')
 sl=d.icon('Security Lists',960,570,parent=v,size=60,label='Explicit app security list\nAll egress / HTTPS ingress only if CIDR supplied',label_pos='top')
 d.connect(subnet,rt,kind='plain',label='route_table_id',exit=(.2338709677,1),entry=(.5,0),straight=True)
 d.connect(subnet,sl,kind='plain',label='security_list_ids',exit=(.7419354839,1),entry=(.5,0),straight=True)
 igw=d.icon('Internet Gateway',330,805,parent=v,size=60,label='Enabled Internet Gateway',label_pos='bottom')
 d.connect(rt,igw,label='Configured default route',exit=(.5,1),entry=(.5,0),straight=True)
 table=d.icon('NoSQL Database',2200,250,parent=r,size=85,label='Regional managed table / create_table=true\nPROVISIONED / read 100 / write 100 / storage 25 GB\nDefault DDL: orders / id primary key\nNot placed in the application subnet',label_pos='top')
 idx=box(d,r,'Optional secondary index / create_table AND create_secondary_index\nIndex flag=false / columns default to customerId',1620,510,1250,125)
 d.connect(idx,table,kind='plain',label='table_name_or_id / index binding',exit=(.464,0),entry=(.5,1),straight=True)
 replica=box(d,r,'Optional replica in supplied second OCI region\ncreate_table AND enable_table_replica / replica flag=false\nregion=null / read 100 / write 100 / no runtime failover proof',1620,820,1250,140)
 d.connect(replica,table,kind='plain',label='table_name_or_id / region / replication configuration',exit=(1,.5),entry=(1,.5),waypoints=[(2940,1050),(2940,410)],label_offset=(-220,0))
 d.text('Optional topic / create_alert_topic=true: no alarm or subscription declared.\nIAM policy / statements=[]: home provider, tenancy fallback.\nTwo terraform_data contracts hold metadata, not deployed services.\nNo app/SDK, private endpoint or table-to-subnet binding is declared.',60,1020,2800,85,parent=r,size=16)
 return finish(d,'DEFAULT RESULT: Seven OCI instances by source defaults: five network resources, one table and one topic; two local metadata contracts also exist.\nTen OCI declarations plus two local contract declarations include the disabled index, replica and policy branches. Default settings can incur charges if applied.\nThe application network is separate from regional NoSQL; no SDK client, service access path, IAM grant, object data or working Internet path is inferred.\nOnly this documentation was generated.')
def mongo(title,index):
 d,r=frame(title,index)
 v=d.group('vcn','Optional VCN / create_private_network=false / 10.80.0.0/16',60,80,1320,920,parent=r)
 subnet=d.group('subnet','Private subnet / 10.80.10.0/24 / no public IP assignment',40,140,1240,210,parent=v)
 sl=d.icon('Security Lists',330,550,parent=v,size=60,label='Explicit empty security list\nNo ingress or egress rules',label_pos='top')
 nsg=d.icon('NSG',960,550,parent=v,size=60,label='Created NSG + stateful ingress per allowed CIDR\nTCP 27017 / allowed CIDRs default to VCN range',label_pos='top')
 d.connect(subnet,sl,kind='plain',label='security_list_ids',exit=(.2338709677,1),entry=(.5,0),straight=True)
 adb=d.icon('Oracle Autonomous Database',2200,250,parent=r,size=85,label='Autonomous Database / enable_mongodb_api_database=false\nAJD workload / ECPU 2 / storage 1 TB / License Included\nNested MONGODB_API tool enabled only on a created database\nThis is Oracle Database with MongoDB API',label_pos='top')
 selected=box(d,r,'Selected database network inputs\nExplicit subnet_id wins over new subnet fallback\nExplicit nonempty nsg_ids win over new NSG fallback\nEndpoint label defaults to mongoapi only when subnet is selected',1620,540,1250,165)
 d.connect(adb,selected,kind='plain',label='subnet_id / nsg_ids / private_endpoint_label',exit=(.5,1),entry=(.464,0),straight=True)
 d.connect(selected,subnet,kind='plain',label='Created subnet fallback only when no explicit subnet ID',exit=(0,0),entry=(1,.5),waypoints=[(1510,700),(1510,485)])
 d.connect(selected,nsg,kind='plain',label='Created NSG fallback only when explicit NSG list empty',exit=(0,.75),entry=(1,.5),waypoints=[(1510,823.75),(1510,790)])
 backup=box(d,r,'Optional manual Autonomous Database backup\nDatabase creation AND create_manual_backup (false)',1620,880,1250,120)
 d.connect(backup,adb,kind='plain',label='autonomous_database_id',exit=(1,.5),entry=(1,.5),waypoints=[(2940,1100),(2940,410)],label_offset=(-170,0))
 d.text('No gateway or explicit route created.\nNew network can remain unused when explicit\nexisting network overrides are supplied.\nIAM policy optional / statements=[] / home provider.',100,780,1150,130,parent=v,size=17)
 return finish(d,'DEFAULT RESULT: No resources; private-network, database and manual-backup flags false; IAM statements empty. Eight OCI declarations.\nCreated DB defaults: compute/storage autoscaling, mTLS required, paid non-free tier. KMS ID and backup retention are optional inputs.\nPublic ACL defaults off; private placement requires an actual selected subnet. A disabled database flag does not create a MongoDB API service.')
def oda(title,index):
 d,r=frame(title,index)
 v=d.group('vcn','Optional application VCN / enable_oda_network=false / 10.86.0.0/16',60,80,1320,920,parent=r)
 subnet=d.group('subnet','Private subnet / 10.86.10.0/24 / no public IP assignment',40,140,1240,210,parent=v)
 rt=d.icon('Route Table',330,550,parent=v,size=60,label='Explicit route table / EMPTY\nNo route rules declared',label_pos='top')
 sl=d.icon('Security Lists',960,550,parent=v,size=60,label='Security list / egress TCP 443\nOnly supplied oda_egress_allowed_cidr',label_pos='top')
 d.connect(subnet,rt,kind='plain',label='route_table_id',exit=(.2338709677,1),entry=(.5,0),straight=True)
 d.connect(subnet,sl,kind='plain',label='security_list_ids',exit=(.7419354839,1),entry=(.5,0),straight=True)
 nsg=d.icon('NSG',960,810,parent=v,size=60,label='Created NSG + egress TCP 443 rule\nSame required egress CIDR',label_pos='bottom')
 service=d.icon('Digital Assistant',2200,190,parent=r,size=80,label='Optional ODA instance / create_oda_instance=false\nDEVELOPMENT shape / role-based access=true\nOptional supplied identity-domain ID',label_pos='top')
 attach=box(d,r,'Optional private endpoint attachment / attach_private_endpoint_to_instance=false\nUses created instance/endpoint when their flags true\nOtherwise oda_instance_id + oda_private_endpoint_id',1620,420,1250,140)
 d.connect(attach,service,kind='plain',label='oda_instance_id / created or supplied selection',exit=(.464,0),entry=(.5,1),straight=True)
 ep=box(d,r,'Optional ODA private endpoint / create_oda_private_endpoint=false\nWith network enabled: created subnet takes precedence over supplied ID\nCreated NSG + additional IDs; otherwise supplied subnet + additional NSGs',1620,760,1250,155)
 d.connect(attach,ep,kind='plain',label='oda_private_endpoint_id / created or supplied selection',exit=(.5,1),entry=(.5,0),straight=True)
 d.connect(ep,subnet,kind='plain',label='Created subnet selection only when network enabled',exit=(0,0),entry=(1,.5),waypoints=[(1510,920),(1510,485)])
 d.connect(ep,nsg,kind='plain',label='Created NSG included only when network enabled',exit=(0,.75),entry=(1,.5),waypoints=[(1510,1036.25),(1510,1050)])
 d.text('No NAT, IGW, service gateway or private DNS.\nHTTPS rules alone do not create a path.\nOptional topic has no subscription or alarm.\nOptional home-provider IAM policy: statements=[].',100,720,650,130,parent=v,size=17)
 d.text('Two terraform_data contracts contain metadata only. No bot, skill, channel, backend application or conversational workload is created.',100,1020,2750,55,parent=r,size=17)
 return finish(d,'DEFAULT RESULT: No OCI resources; all network/service/endpoint/attachment/topic flags false; IAM statements empty. Two local metadata contracts remain.\nEleven OCI resource declarations plus two contracts. Endpoint creation requires a selected subnet and at least one NSG. Attachment requires both selected IDs.\nNetwork creation alone does not attach an endpoint to ODA; endpoint and attachment have independent flags. Existing IDs do not prove active resources or a route.')
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--render',action='store_true');p.add_argument('--blueprint',action='append',choices=[v[0] for v in ITEMS]);a=p.parse_args()
 for i,(slug,title,kind) in enumerate(ITEMS,51):
  if a.blueprint and slug not in a.blueprint:continue
  d=globals()[kind](title,i);warnings=d.check()+d._crossings([n for n in d.nodes if n.kind=='text']);print(slug,warnings,flush=True)
  if warnings:raise RuntimeError('Fix geometry before export')
  path=ROOT/'blueprints'/slug/'architecture/architecture.drawio';d.save(str(path))
  if a.render and not d.render(str(path.with_suffix('.png')),scale=1.5):raise RuntimeError('PNG export failed')
  with path.open('a') as f:f.write('\n')
if __name__=='__main__':main()
