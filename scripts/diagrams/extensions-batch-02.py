#!/usr/bin/env python3
"""Source-bounded catalog continuation 41-45: optional platform extensions."""
import argparse
import importlib.util
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
def load(name):
 spec=importlib.util.spec_from_file_location(name,Path(__file__).with_name(name+'.py'))
 mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod);return mod
base=load('ai-industry-batch-03')
ITEMS=[
 ('extensions/exadata','Exadata | Optional infrastructure capacity; no database stack','exadata'),
 ('extensions/apigw','API Gateway | Optional gateway, deployment and supplied backend routes','apigw'),
 ('extensions/oac','Analytics Cloud | Optional instance and private access channel','oac'),
 ('extensions/oic','Integration | Optional instance and private outbound attachment','oic'),
 ('extensions/observability','Observability | Separate optional services and existing network inputs','observability'),
]
def frame(title,index,scope='OCI / selected region and compartment; tenancy fallback requires review'):
 d=base.network.Diagram(toolkit=base.network.TOOLKIT,title=title)
 d.text(title,20,10,2460,45,size=25,bold=True)
 d.text(f'EXTENSIONS {index:02} / Official OCI Toolkit v24.2 / Source configuration only / No cloud operations',20,65,2460,30,size=13)
 d.text('Plain: ID/configuration association. Solid arrow: configured route intent. Dashed: external prerequisite. No line proves working traffic.',20,108,2460,30,size=13)
 r=d.group('region',scope,20,160,2460,900)
 return d,r
def finish(d,text):return base.finish(d,text)

def exadata(title,index):
 d,r=frame(title,index)
 infra=d.icon('Oracle Exadata Database Service',1200,300,parent=r,size=90,label='Cloud Exadata Infrastructure\nenable_exadata_infrastructure=false',label_pos='top')
 placement=d.box('Operator-selected availability domain\navailability_domain=null\nNo AD lookup or network resources created',60,230,690,140,parent=r,kind='optional')
 d.connect(infra,placement,kind='plain',label='availability_domain',straight=True)
 contacts=d.box('Customer contact configuration\ncustomer_contacts=[] / email entries\nNested blocks; no notification topic created',1690,230,690,140,parent=r,kind='optional')
 d.connect(infra,contacts,kind='plain',label='customer_contacts',straight=True)
 d.box('Capacity inputs / all null by default\nshape / compute_count / storage_count\ndatabase_server_type / storage_server_type\nNo maintenance_window block is declared',60,520,1100,185,parent=r,kind='note')
 d.box('Downstream database stack / NOT CREATED\nVM clusters / DB homes / databases / backups\nVCN / client and backup subnets / NSGs / routes\nPrivate connectivity and operator access are external',1300,520,1080,185,parent=r,kind='note')
 d.text('One resource declaration. Infrastructure OCID is the output hand-off; no VM-cluster association or database traffic is configured.\nThe official Exadata service glyph identifies infrastructure capacity, not a deployed database system.',60,760,2320,90,parent=r,size=17)
 return finish(d,'DEFAULT RESULT: No resources; Exadata infrastructure is opt-in. Shape, placement, server types and capacity require operator review.\nLines show declared placement/contact configuration only. No maintenance policy, VM cluster, database, storage network or application connection is implied.')

def apigw(title,index):
 d,r=frame(title,index)
 net=d.box('Existing subnet + NSGs\nsubnet_id=null / network_security_group_ids=[]\nNo VCN, subnet, NSG, route or gateway created',60,100,850,145,parent=r,kind='optional')
 gateway=d.icon('API Gateway',1700,175,parent=r,size=70,label='Optional API Gateway\nenable_gateway=false AND create_gateway=true\nendpoint_type=PUBLIC / review before enabling',label_pos='top')
 d.connect(gateway,net,kind='plain',label='subnet_id / network_security_group_ids',straight=True)
 cert=d.box('Existing certificate / certificate_id=null\nNo certificate lifecycle resource created',60,340,850,105,parent=r,kind='optional')
 d.connect(gateway,cert,kind='plain',label='Optional certificate_id',exit=(0,.8),entry=(1,.5),waypoints=[(1160,356),(1160,552.5)])
 deployment=d.box('API deployment / enable_deployment=false\npath_prefix=/ / routes=[]\nExisting gateway_id takes precedence; otherwise created gateway ID',1260,365,1100,135,parent=r)
 d.connect(deployment,gateway,kind='plain',label='Created gateway fallback / only when gateway_id=null',exit=(.4,0),entry=(.5,1),straight=True)
 existing=d.box('Existing gateway_id / null by default\nExplicit ID overrides the created gateway for deployment',60,470,850,100,parent=r,kind='optional')
 d.connect(deployment,existing,kind='plain',label='Explicit gateway_id / if non-null',exit=(0,.8),entry=(1,.5),waypoints=[(1220,633),(1220,680)])
 backend=d.box('Supplied per-route backend configuration / EXTERNAL TARGETS\nbackend_type + optional URL or status / methods + timeouts\nNo backend resource, client, authentication policy or application created',1260,665,1100,150,parent=r,kind='optional')
 d.connect(deployment,backend,label='Configured route intent / only populated routes',exit=(.5,1),entry=(.5,0),straight=True)
 d.text('Routes may describe URL backends or status-based responses.\nThe solid arrow describes configured handling, not a guaranteed\nnetwork request to a backend for every backend type.\nNo ingress, DNS, TLS, IAM or backend readiness is verified.',60,620,1050,165,parent=r,size=18)
 return finish(d,'DEFAULT RESULT: No resources; gateway and deployment flags are false. Two independent resource declarations.\nAn existing gateway_id overrides the created gateway for deployment binding; resource_ids.gateway reports only a newly created gateway.\nPUBLIC is a source default, not evidence of Internet reachability. Subnet routes, NSG rules, certificates, backend reachability and authentication require separate implementation.')

def oac(title,index):
 d,r=frame(title,index)
 instance=d.icon('Oracle Analytics Cloud',500,230,parent=r,size=80,label='OAC instance / enable_analytics_instance=false\nENTERPRISE_ANALYTICS / LICENSE_INCLUDED\nCapacity: OLPU_COUNT / 1',label_pos='top')
 ids=d.box('Existing optional service identifiers\nkms_key_id=null / domain_id=null\nNo key or identity domain created',1420,155,930,150,parent=r,kind='optional')
 d.connect(instance,ids,kind='plain',label='kms_key_id / domain_id',straight=True)
 pac=d.box('Private access channel / enable_private_access_channel=false\nCreated instance if enabled; else existing_analytics_instance_id\nprivate_source_dns_zones=[] / DNS zone descriptors only',60,510,1090,160,parent=r)
 d.connect(pac,instance,kind='plain',label='analytics_instance_id',exit=(.40366972,0),entry=(.5,1),straight=True)
 net=d.box('Existing VCN + subnet + NSGs\nvcn_id=null / subnet_id=null / NSGs=[]\nNo network or DNS zone is created',1420,510,930,160,parent=r,kind='optional')
 d.connect(pac,net,kind='plain',label='vcn_id / subnet_id / network_security_group_ids',straight=True)
 d.text('The private access channel is a separate instance attachment using supplied network IDs.\nNo data source, data connection, dataset, workbook, agent, ingress endpoint or content migration is declared.\nemail_notification is an instance property; no notification subscription or delivery path is created.',60,750,2320,105,parent=r,size=18)
 return finish(d,'DEFAULT RESULT: No resources; both creation flags false. Two resource declarations, with optional existing-instance fallback.\nPrivate source DNS zone entries do not create OCI DNS zones or resolver rules. A private channel does not establish an application/data-source connection.')

def oic(title,index):
 d,r=frame(title,index)
 instance=d.icon('Integration',500,230,parent=r,size=80,label='OIC instance / enable_integration_instance=false\nSTANDARDX / is_byol=false / message_packs=1',label_pos='top')
 identity=d.box('Existing identity / domain_id=null or IDCS token\nSTANDARDX / ENTERPRISEX / HEALTHCARE require one\nNo identity domain, credentials or IAM policy created',1420,150,930,160,parent=r,kind='optional')
 d.connect(instance,identity,kind='plain',label='domain_id or idcs_at / precondition',straight=True)
 outbound=d.box('Private outbound connection / enable_private_outbound_connection=false\nCreated instance if enabled; else existing_integration_instance_id\nPreconditions require selected instance ID and outbound subnet ID',60,510,1090,160,parent=r)
 d.connect(outbound,instance,kind='plain',label='integration_instance_id',exit=(.40366972,0),entry=(.5,1),straight=True)
 net=d.box('Existing outbound subnet + NSGs\noutbound_subnet_id=null / outbound_nsg_ids=[]\nNo network, NSG rules, routes or DNS created',1420,510,930,160,parent=r,kind='optional')
 d.connect(outbound,net,kind='plain',label='subnet_id / nsg_ids',straight=True)
 d.text('File server, Visual Builder and disaster recovery flags default to false; consumption model, shape and retention inputs are null.\nNo integration flow, adapter connection, hospital/FHIR endpoint, messaging target or credentials are deployed.\nPrivate outbound attachment is an ID association; actual target access and return routing require separate implementation.',60,745,2320,110,parent=r,size=17)
 return finish(d,'DEFAULT RESULT: No resources; both creation flags false. Exactly two optional resource declarations.\nThe instance type is a source selection, not a deployment or service-availability check. No DR topology or replication is inferred from a feature flag.')

def observability(title,index):
 d,r=frame(title,index,'OCI / selected region; tenancy-root namespace onboarding + compartment-scoped services')
 ns=d.icon('Logging Analytics',500,200,parent=r,size=65,label='Optional namespace onboarding / flag=false\nnamespace=default / is_onboarded=true\ncompartment_id=tenancy_ocid / TENANCY ROOT',label_pos='top')
 log=d.box('Optional Log Analytics log group / flag=false\nWorkload compartment / selected namespace\nNo collector, ingestion source or log payload declared',1420,135,930,135,parent=r)
 d.connect(log,ns,kind='plain',label='namespace / created or supplied value',straight=True)
 apm=d.icon('Application Performance Monitoring',500,510,parent=r,size=70,label='Independent optional APM domain / flag=false\nis_free_tier=true / no agent or exporter configured',label_pos='top')
 pe=d.icon('Operations Insights',1700,510,parent=r,size=70,label='Optional OPSI private endpoint / flag=false\nis_used_for_rac_dbs=false',label_pos='top')
 net=d.box('Existing VCN + subnet + NSGs\nvcn_id=null / subnet_id=null / nsg_ids=[]\nNo network or database onboarding created',1260,690,1100,120,parent=r,kind='optional')
 d.connect(pe,net,kind='plain',label='vcn_id / subnet_id / nsg_ids',exit=(.5,1),entry=(.4,0),straight=True)
 d.text('APM is independent of Log Analytics and OPSI.\nNo service connector, trace/log ingestion, agent,\ndashboard, alarm, subscription or notification\nis declared. No automatic telemetry lines are inferred.',60,690,1050,140,parent=r,size=18)
 return finish(d,'DEFAULT RESULT: No resources; all four service flags false. Namespace onboarding is tenancy-root scope and requires separate review.\nLog group namespace is the optional created namespace string or supplied value; the line is a configuration association, not log delivery.\nOperations Insights endpoint selects existing network IDs.')

def main():
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--render',action='store_true');parser.add_argument('--blueprint',action='append',choices=[i[0] for i in ITEMS]);args=parser.parse_args()
 for index,(slug,title,kind) in enumerate(ITEMS,41):
  if args.blueprint and slug not in args.blueprint:continue
  d=globals()[kind](title,index);warnings=d.check()+d._crossings([n for n in d.nodes if n.kind=='text']);print(slug,warnings,flush=True)
  if warnings:raise RuntimeError('Fix layout warnings before export')
  path=ROOT/'blueprints'/slug/'architecture/architecture.drawio';d.save(str(path))
  if args.render and not d.render(str(path.with_suffix('.png')),scale=1.5):raise RuntimeError('PNG export failed')
  with path.open('a') as stream:stream.write('\n')
if __name__=='__main__':main()
