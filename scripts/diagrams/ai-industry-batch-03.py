#!/usr/bin/env python3
"""Catalog items 31-35: source-bounded AI, DevOps and Telco diagrams."""
import argparse
import importlib.util
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
def load(name):
 spec=importlib.util.spec_from_file_location(name,Path(__file__).with_name(name+'.py'))
 mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod);return mod
base=load('ai-batch-02');network=load('networking-batch-02')
ITEMS=[
 ('ai/embedding-pipeline','Embedding pipeline | Storage, events and external processing','embedding'),
 ('ai/multi-agent','Multi-agent | Agent definitions and external orchestration','multi'),
 ('ai/agents','AI Agents / RAG | Knowledge source, ingestion and agent bindings','agents'),
 ('devops/oci-devops-pipeline','OCI DevOps | Optional project, repository and empty pipeline shells','devops'),
 ('industry/telco-cloud-native','Telco cloud native | Network foundation and optional OKE','telco'),
]
def header(title,index):
 d=network.Diagram(toolkit=network.TOOLKIT,title=title)
 d.text(title,20,10,2460,45,size=25,bold=True)
 d.text(f'AI / DEVOPS / INDUSTRY {index:02} / Official OCI Toolkit v24.2 / Source configuration, not runtime evidence',20,65,2460,30,size=13)
 d.text('Plain lines: ID associations. Solid arrows: configured routes/actions. Dashed: external workflows or prerequisites. No line proves working traffic.',20,108,2460,30,size=13)
 return d
def frame(title,index):
 d=header(title,index)
 r=d.group('region','OCI / selected region and compartment; tenancy fallback requires review',20,160,2460,900)
 return d,r
def policy(d,r,x=2100,y=780):
 d.icon('Policies',x,y,parent=r,size=50,label='Optional IAM policy / statements=[]\nHome provider / tenancy-root compartment fallback',label_pos='top')
def finish(d,text):base.footer(d,text);return d

def embedding(title,index):
 d,r=frame(title,index)
 source=d.icon('OCI Object Storage',150,210,parent=r,size=65,label='Source bucket / create_buckets=false',label_pos='top')
 event=d.icon('Events',730,210,parent=r,size=60,label='Events rule / create_event_rule=false',label_pos='top')
 chunk=d.box('Existing chunking Function\nchunking_function_id=null / not created',1100,145,520,130,parent=r,kind='optional')
 workers=d.box('External embedding + indexing workers\nNot created / application implementation required',1800,145,590,130,parent=r,kind='optional')
 d.connect(source,event,kind='dashed',label='Supplied condition must match source events',straight=True)
 d.connect(event,chunk,label='Declared FAAS action / function_id',straight=True)
 d.connect(chunk,workers,kind='dashed',label='External handoff',straight=True)
 streams=d.icon('OCI Streaming',1020,520,parent=r,size=65,label='chunks + vectors streams\ncreate_streams=false / 1 partition each',label_pos='top')
 pool=d.icon('OCI Streaming',420,520,parent=r,size=60,label='Optional stream pool\ncreate_stream_pool=false / existing ID fallback',label_pos='top')
 target=d.box('Existing model + vector target / EXTERNAL\nembedding_model_id=null / opensearch_endpoint=null\nvector_index_name=documents; inputs exported only',1810,465,580,125,parent=r,kind='optional')
 d.connect(streams,pool,kind='plain',label='stream_pool_id / if selected',straight=True)
 d.connect(workers,streams,kind='dashed',label='External producers / consumers',exit=(0,1),entry=(1,.5),waypoints=[(1720,435),(1720,680)])
 d.connect(workers,target,kind='dashed',label='External model call + index writes',exit=(.5,1),entry=(.5,0),straight=True)
 state=d.icon('OCI Object Storage',580,780,parent=r,size=50,label='State + failed buckets / same bucket flag\nNo writer or retry process deployed',label_pos='top')
 d.connect(chunk,state,kind='dashed',label='External checkpoint / failure writes',exit=(.8,1),entry=(1,.5),waypoints=[(1536,475),(1680,475),(1680,940)])
 d.text('Buckets: private / Standard / versioned / object events enabled.\nExisting KMS key optional for buckets and pool. No key is created.\nAn Events condition is operator supplied; enabling bucket events does not bind this rule.',45,340,1580,95,parent=r,size=15)
 policy(d,r)
 return finish(d,'DEFAULT RESULT: No cloud resources. All creation flags false; policy statements empty; streams map contains chunks and vectors but is gated off.\nSolid event-to-Function arrow is declared configuration; dashed arrows describe application code that is not deployed here. Stream retention is per-entry optional.\nNo Function application, embedding endpoint, search cluster/index, source objects, producer/consumer or retry worker is created.\nNo private network, ingestion, embedding call, indexing, IAM access or working data path was tested. Resource pages enumerate all declarations and existing-resource inputs.')

def multi(title,index):
 d,r=frame(title,index)
 endpoint=d.box('Orchestrator endpoint / create=false\nAgent ID: created orchestrator or supplied ID\nSessions + traces true / citations true',65,160,590,140,parent=r)
 agent=d.box('Orchestrator agent / create=false\nKnowledge-base IDs: explicit list + selected KB\nOptional MODEL or ENDPOINT LLM selection',900,160,640,140,parent=r)
 kb=d.box('Knowledge base / create=false\nOCI_OPEN_SEARCH_INDEX_CONFIG\nExisting OpenSearch cluster ID required',1780,160,600,140,parent=r)
 d.connect(endpoint,agent,kind='plain',label='agent_id',straight=True)
 d.connect(agent,kb,kind='plain',label='knowledge_base_ids',straight=True)
 runtime=d.box('External dispatcher / tool runtime\nNot created / implements delegation and handoffs',60,465,600,120,parent=r,kind='optional')
 specialists=d.box('Specialist agent definitions / specialist_agents={}\nPer-agent knowledge bases and model/endpoint IDs\nNo automatic orchestrator-to-specialist delegation',900,465,640,120,parent=r)
 tools=d.box('Agent tool definitions / agent_tools={}\nExplicit agent_id; else specialist key or orchestrator\nFunction name / description / parameter metadata only',1780,465,600,120,parent=r)
 d.connect(runtime,endpoint,kind='dashed',label='External endpoint invocation',exit=(.5,0),entry=(.5,1),straight=True)
 d.connect(runtime,specialists,kind='dashed',label='External dispatch / delegation',straight=True)
 d.connect(tools,specialists,kind='plain',label='agent_id / selected specialist only',straight=True)
 d.connect(tools,agent,kind='plain',label='Alternative orchestrator binding',exit=(.5,0),entry=(1,1),waypoints=[(2100,560),(1560,560)])
 stream=d.icon('OCI Streaming',300,790,parent=r,size=50,label='Task stream + optional pool / flags=false\n1 partition / 24 h; no task producer deployed',label_pos='top')
 d.connect(runtime,stream,kind='dashed',label='External task producer / consumer',exit=(0,.5),entry=(0,.5),waypoints=[(60,685),(60,950)])
 d.icon('OCI Object Storage',1120,790,parent=r,size=50,label='Audit + tools buckets / create_buckets=false\nPrivate / versioned / no registry loader or audit writer',label_pos='top')
 policy(d,r)
 return finish(d,'DEFAULT RESULT: No resources. Creation flags false; specialist_agents={}, agent_tools={} and policy_statements=[]. Existing IDs may be supplied instead.\nKnowledge base references an existing OpenSearch cluster; no cluster, data source, ingestion job or knowledge population is declared.\nLLM model/endpoint IDs are existing resources. Tool metadata does not deploy executable Functions, authorization or a tool invocation service.\nBucket/pool KMS keys are supplied externally. No network or private endpoint is created; no delegation, retrieval, tool execution or stream consumption was tested.')

def agents(title,index):
 d,r=frame(title,index)
 bucket=d.icon('OCI Object Storage',160,220,parent=r,size=65,label='Source bucket / create_buckets=false',label_pos='top')
 ds=d.box('Data source / create_data_source=false\nOCI_OBJECT_STORAGE_PREFIXES\nCreated source prefix + supplied prefix list',600,150,650,145,parent=r)
 kb=d.box('Knowledge base / create=false\nExisting OpenSearch cluster ID\nOptional index/schema descriptors',1510,150,800,145,parent=r)
 d.connect(ds,bucket,kind='plain',label='Namespace / bucket / prefix binding',straight=True)
 d.connect(ds,kb,kind='plain',label='knowledge_base_id',straight=True)
 job=d.box('One-time ingestion job / create=false\nSelected created or existing data_source_id\nNo schedule or successful ingestion assumed',610,470,630,140,parent=r)
 d.connect(job,ds,kind='plain',label='data_source_id',exit=(.5,0),entry=(.5,1),straight=True)
 agent=d.box('GenAI Agent / create_agent=false\nExplicit KB IDs + selected knowledge base\nOptional existing MODEL or ENDPOINT selection',1510,470,800,140,parent=r)
 d.connect(agent,kb,kind='plain',label='knowledge_base_ids',exit=(.5,0),entry=(.5,1),straight=True)
 endpoint=d.box('Agent endpoint / create_agent_endpoint=false\nSessions / traces / citations true\nNo private-network attachment declared',1510,740,800,100,parent=r)
 d.connect(endpoint,agent,kind='plain',label='agent_id / created or existing',exit=(.5,0),entry=(.5,1),straight=True)
 d.icon('OCI Object Storage',160,580,parent=r,size=55,label='Processed + audit buckets\nSame create_buckets flag\nNo processor or audit writer deployed',label_pos='top')
 policy(d,r,x=700,y=790)
 d.text('All buckets: NoPublicAccess / Standard / versioned / events enabled; optional existing KMS key.\nIndex/schema descriptors reference existing search infrastructure; they do not create a search cluster or a separate managed index resource.',40,325,490,175,parent=r,size=14)
 return finish(d,'DEFAULT RESULT: No cloud resources. All creation flags false; policy statements and explicit KB/prefix lists empty.\nThe source-prefix binding is added only when both bucket creation and data-source creation are enabled; supplied existing prefixes can be appended.\nThe declared ingestion job can initiate one ingestion when explicitly enabled; creation does not prove completion, indexing quality or retrieval.\nNo FaaS processor, chat client, private endpoint, VCN, model hosting or application authentication layer is created. No ingestion or agent request was executed.')

def devops(title,index):
 d,r=frame(title,index)
 d.icon('DevOps',150,170,parent=r,size=70,label='OCI DevOps / optional resources',label_pos='top')
 project=d.box('DevOps project / enable_devops_project=false\nOr reuse existing_project_id',720,130,740,130,parent=r)
 topic=d.icon('Notifications',2110,195,parent=r,size=60,label='Notification topic / create=false\nOr supplied notification_topic_id',label_pos='top')
 d.connect(project,topic,kind='plain',label='notification_config.topic_id',straight=True)
 repo=d.box('Code repository / enable_repository=false\nProject ID binding; repository type + branch inputs',90,470,690,125,parent=r)
 build=d.box('Empty build pipeline / enable_build_pipeline=false\nProject ID binding / no build stages',900,470,650,125,parent=r)
 deploy=d.box('Empty deploy pipeline / enable_deploy_pipeline=false\nProject ID binding / no deploy stages',1700,470,680,125,parent=r)
 for i,node in enumerate([repo,build,deploy]):
  x=node.center()[0]
  d.connect(node,project,kind='plain',label='project_id',exit=(.5,0),entry=(.2+.3*i,1),waypoints=[(x,540),(project.abs[0]+project.w*(.2+.3*i),540)])
 d.text('Exactly five resource declarations: topic, project, repository, build pipeline and deploy pipeline.\nAn existing project can own the repository and shells. No automatic repository → build → deploy execution path is configured.',50,625,2340,75,parent=r,size=16)
 d.text('External implementation required: source connections, triggers, build specification, pipeline stages, artifacts,\ndeployment environments and workload targets. IAM grants, subscriptions and delivery validation are also external.',50,720,2320,100,parent=r,size=17)
 return finish(d,'DEFAULT RESULT: No resources; all five opt-in flags false. Project/topic prerequisites are enforced by blueprint checks.\nPlain lines show the exact project/topic associations only. Empty pipeline shells have no executable stages, no trigger and no build-to-deploy handoff.\nThe blueprint declares no external GitHub/AWS/Azure/GCP resources, artifact repository, network, application deployment or execution.\nThis is a source/diagram review. Historical mocked-plan validation is unchanged; no build, deploy, notification delivery or live cloud test was run.')

def telco(title,index):
 d=network.build(title,'base',index,subtitle='INDUSTRY 35 / Source-pinned network foundation + disabled optional services',scope_note='DEFAULT FOUNDATION: Hub + one three-tier spoke + DRG + IGW/NAT/SGW routes. Optional OKE, Vault, monitoring and OS Management Hub are disabled.\nThe panel on the right shows module bindings, not another physical network. No CNF, Kubernetes workload, service Load Balancer or traffic test is created.')
 p=d.group('other','Optional modules / configuration references to the network at left',1760,160,900,880)
 config=d.box('Hub subnet inputs / default keys\nAPI endpoint = shared (10.0.2.0/24)\nWorker nodes = shared / service LB eligibility = dmz\nNo service Load Balancer resource is created',35,75,830,135,parent=p)
 cluster=d.icon('OCI Container Engine for Kubernetes',230,345,parent=p,size=65,label='OKE cluster / enable_oke_cluster=false\nPrivate API / OCI_VCN_IP_NATIVE',label_pos='top')
 nodes=d.box('Node pool / enable_oke_node_pool=false\n1 node per subnet / node shape + version required\nRoot supplies no node image ID',490,280,365,130,parent=p)
 d.connect(config,cluster,kind='plain',label='VCN / API / service-LB subnet IDs',exit=(0,.8),entry=(0,.5),waypoints=[(1780,343),(1780,505)])
 d.connect(nodes,cluster,kind='plain',label='cluster_id',straight=True)
 d.connect(config,nodes,kind='plain',label='node_subnet_ids',exit=(.8,1),entry=(.5,0),waypoints=[(2459,410),(2432.5,410)])
 vault=d.icon('Vault',120,560,parent=p,size=50,label='Vault / disabled',label_pos='top')
 key=d.icon('Key Management',390,560,parent=p,size=50,label='Key / gated by Vault settings',label_pos='top')
 d.connect(key,vault,kind='plain',label='management_endpoint',straight=True)
 d.text('Vault key is not automatically bound to OKE.\nAlarms/topics/subscriptions are optional map-driven resources;\nno metrics or notification delivery are implied.',35,655,820,90,parent=p,size=14)
 d.text('OS Management Hub / disabled\nGroup + scheduled-job maps empty; managed hosts, software\nsources and group IDs are operator inputs, not OKE outputs.',35,760,820,90,parent=p,size=14)
 d.text('Source pins: network d7938f4; OKE / Vault / Monitoring / OS Management modules v0.2.0.\nNo current module version is substituted. Network default egress paths do not establish pod networking or CNF readiness.\nNative resource-detail pages enumerate every transitive declaration, condition and existing-resource input.',1770,1120,880,150,size=14)
 return d

def main():
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--render',action='store_true');args=parser.parse_args()
 for index,(slug,title,kind) in enumerate(ITEMS,31):
  d=globals()[kind](title,index)
  warnings=d.check()+d._crossings([n for n in d.nodes if n.kind=='text'])
  print(slug,warnings,flush=True)
  if warnings:raise RuntimeError('Fix layout warnings before export')
  path=ROOT/'blueprints'/slug/'architecture/architecture.drawio';d.save(str(path))
  if args.render and not d.render(str(path.with_suffix('.png')),scale=1.5):raise RuntimeError('PNG export failed')
  with path.open('a') as stream:stream.write('\n')
if __name__=='__main__':main()
