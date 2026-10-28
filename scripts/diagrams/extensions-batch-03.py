#!/usr/bin/env python3
"""Five original catalog entries: Streaming, WAF, containers, Functions and Events."""
import argparse,importlib.util
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
def load(name):
 s=importlib.util.spec_from_file_location(name,Path(__file__).with_name(name+'.py'));m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
base=load('extensions-batch-02')
ITEMS=[
 ('extensions/streaming','Streaming | Optional pool and mutually exclusive stream placement','streaming'),
 ('extensions/waf','WAF | Optional empty policy and existing Load Balancer attachment','waf'),
 ('extensions/container-instances','Container Instances | Nested container runtime and existing network inputs','containers'),
 ('extensions/functions','Functions | Optional runtime, image references and configured invocation paths','functions'),
 ('extensions/event-driven-platform','Event-driven platform | Optional actions, streams and connector targets','events'),
]
def frame(title,index,wide=False):
 if not wide:return base.frame(title,index)
 d=base.base.network.Diagram(toolkit=base.base.network.TOOLKIT,title=title)
 d.text(title,20,10,2940,45,size=25,bold=True)
 d.text(f'EXTENSIONS {index:02} / Official OCI Toolkit v24.2 / Source configuration only / No cloud operations',20,65,2940,30,size=13)
 d.text('Plain: ID/configuration association. Solid: configured invocation/delivery intent. Dashed: external prerequisites or source matching. No line proves working traffic.',20,108,2940,30,size=13)
 r=d.group('region','OCI / selected region and compartment; tenancy fallback requires review',20,160,2940,1120)
 return d,r

def finish(d,text,wide=False):
 if not wide:return base.finish(d,text)
 d.box(text,20,1360,2940,160,kind='note')
 d.text('Source and rendered-diagram review: 2026-10-28. Historical Terraform/provider validation metadata is unchanged.\nNo provisioning, image build/pull, invocation, event delivery, application traffic or cloud test was run.',20,1570,2940,60,size=13)
 return d

def streaming(title,index):
 d,r=frame(title,index)
 pool=d.icon('OCI Streaming',500,200,parent=r,size=70,label='Created pool / enable_streaming=false\ncreate_stream_pool=true / streams={}',label_pos='top')
 existing=d.box('Existing pool override / stream_pool_id=null\nExplicit ID takes precedence over a created pool\nNo existing pool configuration is changed',1560,130,840,140,parent=r,kind='optional')
 streams=d.box('Pool-bound streams / stream map entries\nenable_streaming AND (create_stream_pool OR supplied ID)\nPer-entry partitions + optional retention',60,440,1100,140,parent=r)
 standalone=d.box('Alternative compartment-scoped streams\nenable_streaming AND NOT create_stream_pool AND no pool ID\nNo explicit pool association in this declaration',1350,440,1000,140,parent=r)
 d.connect(streams,pool,kind='plain',label='stream_pool_id / created fallback only if supplied ID=null',exit=(.4,0),entry=(.5,1),straight=True)
 d.connect(streams,existing,kind='plain',label='stream_pool_id / explicit override if non-null',exit=(1,.35),entry=(0,.5),waypoints=[(1240,649),(1240,360)])
 config=d.box('Optional created-pool settings / existing identifiers only\nprivate_endpoint_subnet_id=null / private_endpoint_nsg_ids=[]\nkms_key_id=null / no network, NSG or key created\nkafka_settings=null / nested pool settings, not another service',60,690,1100,145,parent=r,kind='optional')
 d.connect(pool,config,kind='plain',label='Optional private_endpoint_settings / custom_encryption_key',exit=(0,.5),entry=(0,.5),waypoints=[(45,360),(45,922.5)],label_offset=(250,0))
 d.text('Three declarations: optional pool plus two mutually exclusive stream branches.\nNo producer, consumer, source data, topic ingestion worker, IAM grant or\npacket path is created. Existing pool override affects stream placement only;\na separately enabled new pool can still be created and remain unused.',1350,690,1000,150,parent=r,size=17)
 return finish(d,'DEFAULT RESULT: No resources; enable_streaming=false and streams empty. create_stream_pool=true is gated by enable_streaming.\nPool-bound and compartment-scoped stream declarations never create the same map entry together. Source partitions/retention are per stream.\nPlain lines show configured IDs only. Private endpoint settings are emitted only with an existing subnet ID; no VCN/subnet/NSG/route or KMS key is created.\nNo producer/consumer authentication, stream publish/read, private DNS, Kafka compatibility or runtime delivery was tested.')

def waf(title,index):
 d,r=frame(title,index)
 policy=d.box('Optional new WAF policy / enable_waf_policy=false\nCompartment, display name and tags only\nNo access/protection/rate-limit rules or actions declared',60,240,690,145,parent=r)
 old=d.box('Existing policy override / waf_policy_id=null\nExplicit ID takes precedence over the newly created policy\nExisting policy rules are not inspected or changed',60,565,690,130,parent=r,kind='optional')
 firewall=d.icon('WAF',1200,300,parent=r,size=85,label='Optional Web App Firewall attachment\nenable_web_app_firewall=false\nbackend_type=LOAD_BALANCER',label_pos='top')
 lb=d.icon('Load Balancer',2100,300,parent=r,size=80,label='Existing Load Balancer / load_balancer_id=null\nNo LB, listener, backend set, certificate or application created',label_pos='top')
 d.connect(firewall,policy,kind='plain',label='Created policy fallback / only if waf_policy_id=null',exit=(0,.5),entry=(1,.5),waypoints=[(1050,460),(1050,472.5)])
 d.connect(firewall,old,kind='plain',label='Explicit policy ID / if supplied',exit=(.5,1),entry=(1,.5),waypoints=[(1220,790)])
 d.connect(firewall,lb,kind='plain',label='load_balancer_id / attachment association',straight=True)
 d.text('Attachment preconditions require both an existing Load Balancer ID and an effective policy ID.\nThe policy is configuration associated with the attachment, not a separate packet-forwarding hop.\nNo Internet ingress, request protection rule, logging, alarm or protected application traffic is inferred.',1000,650,1380,170,parent=r,size=19)
 return finish(d,'DEFAULT RESULT: No resources; both WAF flags false. Two resource declarations: optional policy and optional Load Balancer attachment.\nAn explicit existing policy ID wins even if policy creation is also enabled. The newly created policy can therefore remain unused.\nThe policy declaration has no rule blocks. Creation or association alone is not evidence of configured protection, origin reachability or blocked attacks.\nNo request, rule evaluation, false-positive assessment, TLS behavior, logging or live protection test was run.')

def containers(title,index):
 d,r=frame(title,index)
 sn=d.group('other','Existing supplied subnet / subnet_id=null / no CIDR or exposure inferred',40,80,2380,600,parent=r)
 ci=d.icon('Container Instances',500,200,parent=sn,size=75,label='Container Instance / enable_container_instance=false\nCI.Standard.E4.Flex / 1 OCPU / 2 GB\nRestart ALWAYS / shutdown timeout 30 s',label_pos='top')
 specs=d.box('Nested containers[] / empty by default\nEach image_url is required; commands, args, env and working directory optional\nPer-container CPU/memory limits, mounts and health checks optional\nNo separate container resource declaration',1100,130,1200,140,parent=sn)
 d.connect(specs,ci,kind='plain',label='containers / creation-time nested specifications',straight=True)
 vnic=d.box('Nested VNIC / existing subnet + nsg_ids=[]\nPublic IP=false / private_ip=null / skip_source_dest_check=false\nNo subnet, NSG, route, gateway or standalone VNIC resource',40,400,900,120,parent=sn,kind='optional')
 d.connect(ci,vnic,kind='plain',label='vnics / supplied network identifiers',exit=(.5,1),entry=(.51111111,0),straight=True)
 config=d.box('Optional instance settings / input collections empty\nimage_pull_secrets: existing registry endpoint / optional Vault secret ID\nCustom DNS + volumes[] / CONFIGFILE or supplied type/backing store\nNo registry, secret, DNS server or durable-volume resource created',1100,400,1200,120,parent=sn,kind='optional')
 d.connect(ci,config,kind='plain',label='Image pull / DNS / volumes',exit=(1,.7),entry=(0,.5),waypoints=[(1050,455),(1050,700)],label_offset=(0,80))
 d.icon('Policies',2150,780,parent=r,size=55,label='Independent optional IAM policy / statements=[]\nRegional provider / policy compartment defaults to tenancy',label_pos='top')
 d.text('Availability domain input=null; fault domain optional. Enabling the instance requires at least one container definition.\nContainer image registry access, configured health checks and application ports remain operator/application responsibilities.\nNo resource-principal grants are inferred from a container flag or arbitrary policy statement list.',50,760,1850,110,parent=r,size=17)
 return finish(d,'DEFAULT RESULT: No resources; container instance disabled and IAM policy statements empty. Exactly two resource declarations.\nContainers, VNIC, volumes, DNS, health checks and image-pull settings are nested instance blocks, not independently managed cloud resources here.\nPrivate/public reachability depends on the existing subnet and rules. Resource-principal disabling defaults false per container; access still requires actual reviewed IAM.\nNo image pull, secret retrieval, container start, health probe, application request, persistence, scaling or runtime service readiness was tested.')

def functions(title,index):
 d,r=frame(title,index,True)
 app=d.icon('OCI Functions',450,370,parent=r,size=70,label='Selected Functions application\nCreate if enable_application AND create_application\nOtherwise supplied application_id / creation disabled',label_pos='bottom')
 network=d.box('Created-application inputs / existing identifiers\nSubnet IDs + NSGs / no network created\nOptional signed-image KMS key IDs / tracing domain ID\nConfig, syslog URL and log-line format / no key or APM domain created',40,80,850,130,parent=r,kind='optional')
 d.connect(app,network,kind='plain',label='Creation only: subnet_ids / NSGs / optional config',exit=(.5,0),entry=(.48235294,1),straight=True)
 fn=d.icon('OCI Functions',1450,370,parent=r,size=75,label='Function definitions / enable_functions=false / functions={}\nTargets: created Functions OR explicit existing Function IDs\nCreated-function defaults: 256 MB / timeout 30 s',label_pos='top')
 d.connect(fn,app,kind='plain',label='Created Functions only: selected application_id',straight=True)
 images=d.box('Per-function source and optional configuration\nsource_details.image / image_digest are supplied per function\nOptional trace flag / provisioned concurrency\nOptional success/failure destination kind + channel/queue/stream/topic IDs\nNo target services or application image build is created here',1100,745,850,220,parent=r,kind='optional')
 d.connect(fn,images,kind='plain',label='Created Functions only: image / optional settings',exit=(.5,1),entry=(.41176471,0),straight=True)
 repo=d.icon('OCI Container Registry',450,855,parent=r,size=65,label='Optional OCIR repository / enable_container_repository=false\nPrivate / mutable defaults / repository URL is output only',label_pos='top')
 d.connect(repo,images,kind='dashed',label='External build/push; copy image URL into function input',straight=True)
 evt=d.icon('Events',2500,200,parent=r,size=60,label='Optional Events rules / enable_event_rules=false\nevent_rules={} / FAAS actions only\nPer-action function ID or created-function key',label_pos='top')
 d.connect(evt,fn,label='Optional FAAS: created function_key OR supplied function_id',exit=(0,.5),entry=(1,.5),waypoints=[(2070,360),(2070,530)])
 dep=d.box('Optional API deployment / enable_api_gateway_deployment=false\nORACLE_FUNCTIONS_BACKEND / function ID or created key\nExplicit api_routes override a synthesized default route\nDefault route key=null / path /hello / GET + POST when selected',2110,500,760,130,parent=r)
 d.connect(dep,fn,label='Optional backend: created key OR supplied function_id',exit=(0,.5),entry=(1,.75),waypoints=[(2070,725),(2070,548.75)])
 gateway=d.icon('API Gateway',2500,890,parent=r,size=70,label='Selected API Gateway / PRIVATE default when created\nCreate if enable_api_gateway AND create_gateway; else gateway_id\nExisting subnet, NSGs, certificate IDs / no network created',label_pos='bottom')
 d.connect(dep,gateway,kind='plain',label='local.gateway_id / created or supplied selection',exit=(.51315789,1),entry=(.5,0),straight=True)
 d.icon('Policies',450,1050,parent=r,size=50,label='Independent optional IAM policy / statements=[]\nHome provider / policy compartment defaults to tenancy',label_pos='top')
 d.text('Function creation uses supplied images; code builds/pushes remain external.\nNo target-service creation, caller auth policy, DNS or automatic image binding.\nTracing and result-destination delivery still need runtime verification.',40,600,850,100,parent=r,size=17)
 return finish(d,'DEFAULT RESULT: No resources; all creation/enable flags false, function/event/API-route maps empty and IAM statements empty. Seven declarations.\nCreated application/gateway selection requires both their enable and create flags; existing IDs are selected otherwise. No new settings are applied to existing services.\nAPI route actions and FAAS event actions are declared invocation intent. External function IDs need not select the created Function collection.\nRepository URL is an output/reference only, not the function image input. No public API exposure, caller authentication, image build/pull or successful invocation was tested.',True)

def events(title,index):
 d,r=frame(title,index,True)
 evt=d.icon('Events',500,190,parent=r,size=60,label='Optional Events rules / create_event_rules=false\nevent_rules={} / configured action_type + target fields',label_pos='top')
 fn=d.box('Existing FAAS action Function / explicit function_id\nNo Function application, image or function is created here',1100,115,850,150,parent=r,kind='optional')
 topic=d.icon('Notifications',2500,190,parent=r,size=65,label='Topic targets / create_topic=false\nCreated topic or topic_id fallback / per-action override allowed\nNo subscription, recipient or delivery validation',label_pos='top')
 d.connect(evt,fn,label='Optional FAAS action / declared function_id',straight=True)
 d.connect(evt,topic,label='Optional ONS action / explicit topic_id or selected fallback',exit=(1,.8),entry=(.5,1),waypoints=[(980,368),(980,470),(2520,470)])
 streams=d.box('Stream declarations / create_streams=false\nevents + deadletter defaults / one partition each\nMutually exclusive compartment or selected-pool placement\nNames do not install a DLQ processor, consumer or retry workflow',1100,525,850,130,parent=r)
 d.connect(evt,streams,label='Optional OSS action / supplied stream ID or stream_key',exit=(.5,1),entry=(.41176471,0),waypoints=[(520,550),(1470,550)])
 pool=d.icon('OCI Streaming',2500,590,parent=r,size=65,label='Selected stream pool / create_stream_pool=false\nCreated pool if enabled; else stream_pool_id\nOptional existing KMS key on created pool',label_pos='top')
 d.connect(streams,pool,kind='plain',label='Only in_pool branch: stream_pool_id',straight=True)
 bucket=d.icon('OCI Object Storage',500,590,parent=r,size=65,label='Optional archive bucket / create_archive_bucket=false\nPrivate / Standard / versioning Enabled / object events on\nOptional existing KMS key; default name is not proof of existence',label_pos='top')
 d.connect(bucket,evt,kind='dashed',label='External event condition must match the chosen bucket',exit=(0,.5),entry=(0,.5),waypoints=[(100,750),(100,350)],label_offset=(90,0))
 connector=d.icon('Service Connector Hub',1450,930,parent=r,size=65,label='Optional connector / create_service_connector=false\nSource: explicit connector_source_stream_id\nor selected stream key (events default)',label_pos='left')
 d.connect(streams,connector,label='Streaming source / when explicit source ID=null',exit=(.41176471,1),entry=(.5,0),straight=True)
 target=d.box('Alternative target configuration / one kind selected\nobjectStorage override: supplied namespace + bucket name\nfunctions: connector_target_function_id\nstreaming: connector_target_stream_id\nnotifications: explicit target topic ID or selected topic\nNo external target service is created by these identifiers',2110,840,760,180,parent=r,kind='optional')
 d.connect(connector,target,kind='plain',label='Target kind + supplied identifiers',straight=True)
 d.connect(connector,bucket,label='objectStorage / default bucket + namespace (no overrides)',exit=(.5,1),entry=(1,.5),waypoints=[(1470,1250),(950,1250),(950,750)],label_offset=(150,60))
 d.icon('Policies',450,1050,parent=r,size=50,label='Independent optional IAM policy / statements=[]\nHome provider / policy compartment defaults to tenancy',label_pos='top')
 d.text('No Functions, source objects, publisher, consumer or retry worker.\nNo automatic bucket→Events match, stream DLQ or alarm subscription.\nKMS key IDs are references only. Namespace lookup is read-only and\nonly runs when create_archive_bucket=true.',40,800,850,165,parent=r,size=17)
 return finish(d,'DEFAULT RESULT: No resources; all create flags false and IAM statements empty. Eight resource declarations plus a gated namespace lookup.\nEach selected Events action requires matching conditions, service permissions and reachable targets. FAAS IDs, OSS stream IDs/keys and ONS topics are independently supplied.\nService Connector selects one target kind: objectStorage default, or supplied Function/stream/topic. Explicit target bucket/namespace override fallback values.\nThe bucket-name fallback can exist even when bucket creation is disabled; an existing bucket/namespace must actually exist. No object write, event delivery, stream processing, retry or alert was tested.',True)

def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--render',action='store_true');p.add_argument('--blueprint',action='append',choices=[v[0] for v in ITEMS]);a=p.parse_args()
 for i,(slug,title,kind) in enumerate(ITEMS,46):
  if a.blueprint and slug not in a.blueprint:continue
  d=globals()[kind](title,i);w=d.check()+d._crossings([n for n in d.nodes if n.kind=='text']);print(slug,w,flush=True)
  if w:raise RuntimeError('Fix geometry before export')
  path=ROOT/'blueprints'/slug/'architecture/architecture.drawio';d.save(str(path))
  if a.render and not d.render(str(path.with_suffix('.png')),scale=1.5):raise RuntimeError('PNG export failed')
  with path.open('a') as f:f.write('\n')
if __name__=='__main__':main()
