#!/usr/bin/env python3
"""Five source-bounded AI overviews with explicit service and cloud connections."""
import argparse
import importlib.util
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
def load(name):
 spec=importlib.util.spec_from_file_location(name,Path(__file__).with_name(name+'.py'))
 mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod);return mod
base=load('data-ai-batch-01');cloud=load('cloud-icons')
ITEMS=[
 ('ai/genai-gateway','GenAI gateway | HTTP routes and optional usage plans','gateway'),
 ('ai/azure-oci-ai-gateway','Azure + OCI AI gateway | Static HTTP routing and external adapters','azure'),
 ('ai/genai-fine-tuning','GenAI fine-tuning | Training capacity, model and separate hosting','tuning'),
 ('ai/genai-guardrails','GenAI guardrails | Log transport and optional monitoring hooks','guardrails'),
 ('ai/document-intelligence','Document intelligence | Event-to-function handoff and external jobs','document'),
]
def header(title,index):return base.header(title,index)
def footer(d,text):base.base.footer(d,text)

def gateway(title,index):
 d=header(title,index)
 reg=d.group('region','OCI / selected region and compartment (tenancy fallback)',20,160,2460,900)
 net=d.group('other','Existing network / supplied subnet, NSGs and optional certificate',40,90,2380,420,parent=reg)
 gw=d.icon('API Gateway',220,200,parent=net,size=75,label='API Gateway / create_gateway=false\nPRIVATE endpoint default',label_pos='top')
 dep=d.box('API deployment / create_deployment=false\nPath prefix /genai / routes={}\nPer route: methods, HTTP_BACKEND URL and timeouts\nTLS verification controlled per route',540,130,780,150,parent=net)
 backend=d.box('Existing model / HTTP inference adapter\nEXTERNAL / URLs supplied in routes\nNo model, endpoint or auth adapter is created',1540,130,760,150,parent=net,kind='optional')
 d.connect(gw,dep,kind='plain',label='gateway_id',straight=True)
 d.connect(dep,backend,kind='dashed',label='Configured HTTP URL / external backend',straight=True)
 plan=d.box('Usage plans / create_usage_plans=false\nusage_plans={} / entitlements target deployment IDs\nOptional request quotas + rate limits (not token budgets)',570,580,1010,140,parent=reg)
 d.connect(plan,dep,kind='plain',label='Target deployment',exit=(.5,0),entry=(.5,1),waypoints=[(1095,700),(990,700)])
 d.icon('OCI Object Storage',240,780,parent=reg,size=55,label='Optional private audit bucket\nStandard / versioned / events enabled',label_pos='top')
 d.icon('Logging',1720,780,parent=reg,size=55,label='Optional log group\nNo log resource, source binding or log sink declared',label_pos='top')
 d.icon('Policies',2210,780,parent=reg,size=50,label='Optional IAM policy\nHome provider / statements=[]',label_pos='top')
 footer(d,'DEFAULT RESULT: No cloud resources. Gateway, deployment, usage plans, audit bucket and log group creation flags are false; policy statements empty.\nGateway/deployment IDs can reuse existing resources. Creating a private gateway does not create a private network or a working client/backend path.\nNo subscriber/API-key bootstrap, authentication policy, OCI request signing, AI payload translation or dynamic model selection is implemented.\nAudit bucket and log group are independent optional containers; there is no automatic request logging or object writer.')
 return d

def azure(title,index):
 d=header(title,index)
 reg=d.group('region','OCI primary / selected region and compartment',20,160,1180,900)
 vc=d.group('vcn','Optional gateway VCN / network flag=true\n10.82.0.0/16',30,70,1120,540,parent=reg)
 sn=d.group('subnet','Gateway subnet / public IPs permitted\n10.82.10.0/24',40,100,1040,200,parent=vc)
 gw=d.icon('API Gateway',150,110,parent=sn,size=60,label='PUBLIC gateway\ncreate flag=true',label_pos='top')
 dep=d.box('API deployment / create flag=true\n/ai + 5 POST routes / static provider mapping\n/providers/oci; /providers/azure\n/route/region; /route/cost; /route/data-residency',390,60,600,110,parent=sn)
 d.connect(gw,dep,kind='plain',label='Gateway binding',straight=True)
 rt=d.icon('Route Table',800,410,parent=vc,size=48,label='Default route',label_pos='top')
 igw=d.icon('Internet Gateway',1120,410,parent=vc,size=50,label='IGW',label_pos='top',border=True)
 d.connect(sn,rt,kind='plain',exit=(.8,1),entry=(.5,0),waypoints=[(922,580),(850,580)])
 d.connect(rt,igw,label='0.0.0.0/0',straight=True)
 d.text('SL: TCP 80/443 from 0.0.0.0/0 default; all egress.\nNo OCI model or inference adapter is created.',30,475,1050,55,parent=vc,size=14)
 oci=d.box('Existing OCI inference HTTP adapter / endpoint\nEXTERNAL URL input; not created\nRequest signing and payload translation external',40,660,500,100,parent=reg,kind='optional')
 d.connect(dep,oci,kind='dashed',label='OCI HTTP_BACKEND URL',label_offset=(130,0),exit=(.2,1),entry=(.5,0),waypoints=[(600,550),(35,550),(35,790),(310,790)])
 d.icon('Logging',650,790,parent=reg,size=48,label='Routing log group / enabled\nNo log collection binding',label_pos='top')
 d.icon('OCI Object Storage',1000,790,parent=reg,size=48,label='Audit bucket / enabled\nPrivate / Standard / versioned',label_pos='top')
 az=d.group('thirdparty','Azure / separately deployed Bicep / resource-group location',1300,160,1180,900)
 net=d.group('thirdparty','VNet 10.92.0.0/16 / subnet 10.92.10.0/23\nUDR → Internet; NSG HTTP/HTTPS + VNet east-west',30,70,1120,330,parent=az)
 env=cloud.box(d,'Microsoft.App/containerApps','Managed Environment + Container App\nDelegated subnet / external ingress / target port 80 / insecure=false\nHello-world image; 0.5 CPU / 1Gi / 1–2 replicas; not an inference adapter',40,130,1040,125,parent=net)
 logs=cloud.icon(d,'Microsoft.OperationalInsights/workspaces',150,480,parent=az,size=55,label='Log Analytics / 30 days',label_pos='bottom')
 apim=cloud.icon(d,'Microsoft.ApiManagement/service',520,480,parent=az,size=55,label='API Management / Consumption\nPublic network access enabled',label_pos='top')
 account=cloud.icon(d,'Microsoft.CognitiveServices/accounts',950,480,parent=az,size=65,label='Azure OpenAI account / S0\nPublic network / local auth enabled',label_pos='top')
 model=d.box('Optional model deployment / false\ngpt-4o-mini / 2024-07-18\nStandard / capacity 20',790,660,340,90,parent=az,kind='optional')
 adapter=d.box('EXTERNAL inference adapter\nNot the hello-world Container App\nAPIM APIs, backend policies and auth not configured',360,640,390,110,parent=az,kind='optional')
 d.connect(env,logs,label='Environment logs',exit=(.1,1),entry=(.5,0),straight=True)
 d.connect(apim,adapter,kind='dashed',label='API/backend policy external',exit=(.5,1),entry=(.5,0),straight=True)
 d.connect(adapter,account,kind='dashed',label='External authenticated inference',exit=(.5,0),entry=(.5,1),waypoints=[(1855,720),(2250,720)])
 d.connect(account,model,kind='plain',label='Parent account',exit=(1,.5),entry=(1,.5),waypoints=[(2450,640),(2450,865)])
 d.connect(dep,adapter,kind='dashed',label='Azure backend URL / external adapter',label_offset=(125,150),exit=(.5,1),entry=(0,.5),waypoints=[(780,560),(1240,560),(1240,855)])
 footer(d,'DEFAULT INPUTS ARE INCOMPLETE: OCI network/gateway/deployment/bucket/log group enabled, but both provider inference URLs and circuit IDs are null.\nInterconnect mode requires existing FastConnect + ExpressRoute IDs; no circuits/DRG/private peering are created here. HTTP routes do not establish private transport.\nRegion/cost/residency routes use operator-selected static provider mappings (OCI/Azure/OCI defaults); no real-time pricing, geolocation or residency enforcement.\nFour local contracts record network/connectivity/routing/Azure outputs. Usage plans disabled; IAM statements empty.')
 return d

def tuning(title,index):
 d=header(title,index)
 reg=d.group('region','OCI GenAI managed regional resources / no network or private endpoint created',20,160,2460,900)
 bucket=d.icon('OCI Object Storage',220,260,parent=reg,size=65,label='Training bucket / create=false',label_pos='top')
 cluster=d.icon('OCI Generative AI',800,260,parent=reg,size=70,label='Dedicated AI cluster / create=false\nFINE_TUNING / 1 × LARGE_COHERE',label_pos='top')
 model=d.icon('OCI Generative AI',1400,260,parent=reg,size=70,label='Fine-tuned model / create=false',label_pos='top')
 endpoint=d.icon('OCI Generative AI',2100,260,parent=reg,size=70,label='Inference endpoint / create=false',label_pos='top')
 d.connect(cluster,model,kind='plain',label='fine_tune_details.dedicated_ai_cluster_id',straight=True)
 d.connect(model,endpoint,kind='plain',label='model_id',straight=True)
 d.connect(bucket,model,kind='plain',label='Training dataset / selected bucket reference',exit=(1,.5),entry=(.5,1),waypoints=[(600,420),(600,680),(1280,680),(1280,480),(1420,480)])
 d.text('Private / Standard / versioned / events\nExisting KMS key optional\nNo dataset upload or preprocessing',40,365,520,100,parent=reg,size=15)
 d.text('One created cluster selects one type.\nTraining config: TFEW_TRAINING_CONFIG\nEpochs / batch size / learning rate null',610,365,640,100,parent=reg,size=15)
 d.text('Base model and cluster IDs can be supplied.\nDataset: datasets/training.jsonl\nNamespace required for existing bucket',1290,365,620,100,parent=reg,size=15)
 base_model=d.box('Existing compatible base_model_id\nEXTERNAL model selection / required for tuning',1090,570,560,95,parent=reg,kind='optional')
 hosting=d.box('Separate compatible HOSTING cluster ID\nRequired when the created cluster is FINE_TUNING\nAlternative: create a HOSTING-only cluster, reuse model',1790,570,610,120,parent=reg,kind='optional')
 d.connect(base_model,model,kind='plain',label='base_model_id',exit=(.5,0),entry=(1,.8),waypoints=[(1390,705),(1980,705),(1980,480),(1475,480),(1475,441)])
 d.connect(hosting,endpoint,kind='plain',label='hosting cluster reference',exit=(.5,0),entry=(.5,1),straight=True)
 d.text('Optional existing generative_ai_private_endpoint_id can attach the inference endpoint.\nIts null default does not establish private transport; this blueprint creates no private endpoint or subnet.\nOptional IAM policy uses the home provider; policy compartment defaults to tenancy root.',50,785,2300,95,parent=reg,size=16)
 footer(d,'DEFAULT RESULT: No cloud resources; all creation flags false and policy statements empty.\nA FINE_TUNING cluster must not be reused for inference hosting. Supplying a HOSTING cluster enables the separate endpoint path.\nModel creation references the dataset object but does not upload/curate training data.\nNo inference call, private access, quality evaluation or production readiness is verified by this diagram.')
 return d

def guardrails(title,index):
 d=header(title,index)
 reg=d.group('region','OCI / optional telemetry transport and governance resources',20,160,2460,900)
 src=d.box('Existing Logging source / explicit log-group ID required\nconnector_source_log_group_id=null\nOptional log_id filter; compartment is the selected compartment',100,200,650,170,parent=reg,kind='optional')
 connector=d.icon('Service Connector Hub',1080,280,parent=reg,size=70,label='Logging service connector / create=false',label_pos='top')
 bucket=d.icon('OCI Object Storage',2130,280,parent=reg,size=65,label='Audit bucket / create=false\nPrivate / Standard / versioned / events',label_pos='top')
 stream=d.box('Existing Streaming stream ID\nAlternative target_kind=streaming\nNo stream is created',1850,450,550,100,parent=reg,kind='optional')
 d.connect(src,connector,kind='plain',label='Explicit log source',straight=True)
 d.connect(connector,bucket,label='objectStorage target / default; prefix genai-guardrails/',straight=True)
 d.connect(connector,stream,label='Alternative streaming target / supplied stream ID',exit=(.5,1),entry=(0,.5),waypoints=[(1100,660)])
 lg=d.icon('Logging',300,650,parent=reg,size=55,label='Optional new log group / create=false\nNot automatically selected as connector source',label_pos='top')
 d.connect(lg,src,kind='dashed',label='Operator explicitly supplies group ID',label_offset=(155,0),exit=(0,.5),entry=(0,.5),waypoints=[(70,810),(70,445)])
 d.icon('Cloud Guard',1050,740,parent=reg,size=60,label='Optional detector recipe / create=false\nSource recipe + detector inputs null\nNo Cloud Guard target or recipe assignment created',label_pos='top')
 alarm=d.box('Alarms / alarms={}\nMetric namespace, query and severity per entry',1300,650,400,120,parent=reg)
 topic=d.box('Existing notification destination IDs\nPer-alarm destinations override\nnotification_topic_id fallback (null)',1900,650,480,120,parent=reg,kind='optional')
 d.connect(alarm,topic,kind='plain',label='Alarm destinations',straight=True)
 d.text('Optional IAM policy and existing KMS key references remain separately supplied.\nNo application logger, PII processor, policy enforcement code or token metric emitter is created.',50,820,2300,65,parent=reg,size=15)
 footer(d,'DEFAULT RESULT: No resources. Creation flags false; alarms={} and policy_statements=[].\nCreating a log group does not wire a producer or automatically set connector_source_log_group_id; the source ID is an explicit prerequisite.\nObject Storage targets can use the created bucket/namespace or explicit overrides. Streaming is an alternative, not a second simultaneous sink.\nThe Cloud Guard recipe is a configurable placeholder, not an implemented PII/GenAI detector.')
 return d

def document(title,index):
 d=header(title,index)
 reg=d.group('region','OCI / document foundation plus existing function handoff',20,160,2460,900)
 intake=d.icon('OCI Object Storage',220,220,parent=reg,size=65,label='Intake bucket',label_pos='top')
 event=d.icon('Events',820,220,parent=reg,size=60,label='Intake event rule / create=false\ncondition=null; operator must scope it',label_pos='top')
 handler=d.box('Existing handler Function ID\nEXTERNAL application code / not created\nhandler_function_id=null',1250,150,500,150,parent=reg,kind='optional')
 project=d.icon('Document Understanding',2150,220,parent=reg,size=65,label='Document project / create=false\nProject is a container, not an OCR job',label_pos='top')
 d.connect(intake,event,kind='dashed',label='Event match requires supplied condition',straight=True)
 d.connect(event,handler,label='FAAS action / function_id',straight=True)
 d.connect(handler,project,kind='dashed',label='External Document API job',straight=True)
 output=d.icon('OCI Object Storage',1800,640,parent=reg,size=65,label='Output bucket',label_pos='top')
 failed=d.icon('OCI Object Storage',2300,640,parent=reg,size=65,label='Failed bucket',label_pos='top')
 d.connect(handler,output,kind='dashed',label='External result writes',exit=(.5,1),entry=(0,.5),waypoints=[(1520,800)])
 d.connect(handler,failed,kind='dashed',label='External failure writes',exit=(.8,1),entry=(1,.5),waypoints=[(1670,650),(2450,650),(2450,800)])
 d.text('create_buckets=false gates a map with intake / output / failed buckets.\nAll private / Standard / versioned / events enabled; optional existing KMS key.\nNo objects, event condition, Function application, job or retry/dead-letter worker is created.',50,460,1250,130,parent=reg,size=16)
 d.icon('Policies',280,780,parent=reg,size=55,label='Optional IAM policy / statements=[]\nHome provider; policy compartment defaults tenancy root',label_pos='top')
 footer(d,'DEFAULT RESULT: No cloud resources. Bucket, Document project and event-rule creation flags false; policy statements empty.\nObject events being enabled does not bind the event condition to the intake bucket. The operator must scope and validate event_rule_condition and supply the function ID.\nHandler → OCR → output/failure lines describe external code that this blueprint does not deploy.\nThe blueprint does not declare any GenAI model/endpoint or private network. Runtime processing and service access require separate implementation and testing.')
 return d

def main():
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--render',action='store_true');args=parser.parse_args()
 for index,(slug,title,kind) in enumerate(ITEMS,26):
  d=globals()[kind](title,index);warnings=d.check();print(slug,warnings,flush=True)
  if warnings:raise RuntimeError('Fix layout warnings before export')
  path=ROOT/'blueprints'/slug/'architecture/architecture.drawio';d.save(str(path))
  if args.render and not d.render(str(path.with_suffix('.png')),scale=1.5):raise RuntimeError('PNG export failed')
  with path.open('a') as stream:stream.write('\n')
if __name__=='__main__':main()
