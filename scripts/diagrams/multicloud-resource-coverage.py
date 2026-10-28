#!/usr/bin/env python3
"""Resource-detail companions for cross-cloud architecture overviews.

Enumerates resource declarations (not resolved instance counts) in root Terraform,
transitive pinned local-repository modules and companion Bicep/CloudFormation.
Creates one editable/PNG resource map per cloud plus an auditable JSON inventory.
Overview diagrams remain the topology view. Run --render for PNG export.
"""
import argparse
import base64
import hashlib
import importlib.util
import json
import html
from pathlib import Path
import re
import subprocess
import textwrap
import copy
from functools import lru_cache
import xml.etree.ElementTree as ET

ROOT=Path(__file__).resolve().parents[2]
spec=importlib.util.spec_from_file_location('networking_batch_02',Path(__file__).with_name('networking-batch-02.py'))
base=importlib.util.module_from_spec(spec); spec.loader.exec_module(base)
icon_spec=importlib.util.spec_from_file_location('cloud_icons',Path(__file__).with_name('cloud-icons.py'))
cloud_icons=importlib.util.module_from_spec(icon_spec); icon_spec.loader.exec_module(cloud_icons)
DEFAULTS=[
 'industry/secure-desktops',
 'extensions/oke',
 'extensions/aks-oke-active-passive',
 'extensions/eks-oke-active-passive',
 'extensions/oke-service-mesh',

 'ai/embedding-pipeline',
 'ai/multi-agent',
 'ai/agents',
 'devops/oci-devops-pipeline',
 'industry/telco-cloud-native',

 'industry/healthcare-fhir-integration',
 'industry/healthcare-platform',
 'ai/genai-gateway',
 'ai/azure-oci-ai-gateway',
 'ai/genai-fine-tuning',
 'ai/genai-guardrails',
 'ai/document-intelligence',
 'networking/aws-oci-managed-interconnect',
 'networking/gcp-oci-partner-interconnect',
 'networking/hub-spoke-with-azure-vwan-expressroute',
 'networking/azure-vwan-oci-drg-transit',
 'networking/azure-oci-dual-connectivity',
 'networking/aws-oci-hybrid-network-backbone',
 'disaster-recovery/azure-oci-cross-cloud-dr',
 'disaster-recovery/aws-oci-cross-cloud-dr',
 'data-platform/autonomous-database',
 'data-platform/private-data-platform',
 'data-platform/postgresql',
 'data-platform/apex-adw',
 'data-platform/opensearch',
 'data-platform/mysql-heatwave',
 'data-platform/oci-aws-mysql-heatwave-dr',
 'ai/genai-private',
 'ai/ai-services',
]
DECL=re.compile(r'^(resource|data|module)\s+"([^"]+)"(?:\s+"([^"]+)")?\s*\{',re.M)
ICONS={
 'oci_health_checks_http_monitor':'Health Checks',
 'oci_dns_steering_policy':'DNS',
 'oci_apm_apm_domain':'Application Performance Monitoring',
 'oci_containerengine_cluster':'OCI Container Engine for Kubernetes',
 'oci_queue_queue':'OCI Queue',
 'oci_apigateway_gateway':'API Gateway',
 'oci_generative_ai_dedicated_ai_cluster':'OCI Generative AI',
 'oci_generative_ai_model':'OCI Generative AI',
 'oci_generative_ai_endpoint':'OCI Generative AI',
 'oci_sch_service_connector':'Service Connector Hub',
 'oci_cloud_guard_detector_recipe':'Cloud Guard',
 'oci_opensearch_opensearch_cluster':'OpenSearch',
 'oci_mysql_mysql_db_system':'MySQL Database System',
 'oci_mysql_heat_wave_cluster':'MySQL HeatWave',
 'oci_ai_document_project':'Document Understanding',
 'oci_ai_language_project':'OCI Language',
 'oci_ai_vision_project':'OCI Vision',
 'oci_core_vcn':'VCN (Region Identifier)','oci_core_subnet':None,
 'oci_core_drg':'DRG','oci_core_drg_attachment':None,
 'oci_core_internet_gateway':'Internet Gateway','oci_core_nat_gateway':'NAT Gateway',
 'oci_core_service_gateway':'Service Gateway','oci_core_route_table':'Route Table',
 'oci_core_security_list':'Security Lists','oci_core_cpe':'Customer Premises Equipment',
 'oci_core_ipsec':None,'oci_core_virtual_circuit':None,
 'oci_objectstorage_bucket':'OCI Object Storage','oci_ons_notification_topic':'Notifications',
 'oci_database_autonomous_database':'Oracle Autonomous Database',
 'oci_psql_db_system':'OCI Database with PostgreSQL',
 'oci_kms_vault':'Vault','oci_streaming_stream_pool':'OCI Streaming',
 'oci_streaming_stream':'OCI Streaming','oci_load_balancer_load_balancer':'Load Balancer',
 'oci_identity_compartment':'Compartments',
 'oci_identity_tag_namespace':'Tagging','oci_identity_tag':'Tagging',
 'oci_identity_tag_default':'Tagging',
 'oci_logging_log_group':'Logging','oci_logging_log':'Logging',
 'oci_logging_log_saved_search':'Logging','oci_audit_configuration':'Auditing',
 'oci_cloud_guard_cloud_guard_configuration':'Cloud Guard',
 'oci_cloud_guard_target':'Cloud Guard','oci_cloud_guard_security_zone':'Maximum Security Zone',
 'oci_kms_key':'Key Management',
 'oci_vulnerability_scanning_host_scan_recipe':'Vulnerability Scanning',
 'oci_vulnerability_scanning_host_scan_target':'Vulnerability Scanning',
 'oci_vulnerability_scanning_container_scan_recipe':'Vulnerability Scanning',
 'oci_vulnerability_scanning_container_scan_target':'Vulnerability Scanning',
 'oci_ons_subscription':'Notifications','oci_events_rule':'Events',
 'oci_monitoring_alarm':'Alarms','oci_identity_group':'User Group',
 'oci_identity_dynamic_group':'IAM','oci_identity_policy':'Policies',
 'oci_data_safe_target_database':'Data Safe',
 'oci_network_firewall_network_firewall_policy':'Firewall',
 'oci_network_firewall_network_firewall':'Firewall',
 'oci_disaster_recovery_dr_protection_group':'Fullstack Disaster Recovery',
 'oci_disaster_recovery_dr_plan':'Fullstack Disaster Recovery',
 'oci_identity_domain':'IAM','oci_identity_domain_replication_to_region':'IAM',
 'oci_core_instance':'OCI Compute','oci_core_vnic_attachment':'VNIC',
 'oci_bastion_bastion':'Bastion','oci_dns_view':'DNS',
 'oci_dns_zone':'DNS','oci_dns_resolver':'DNS','oci_dns_resolver_endpoint':'DNS',
 'oci_core_network_security_group':'NSG',
 'oci_core_network_security_group_security_rule':'NSG',
}


@lru_cache(maxsize=None)
def read_sources(folder,ref=None):
 if ref:
  names=subprocess.check_output(['git','ls-tree','--name-only',f'{ref}:{folder}'],cwd=ROOT,text=True).splitlines()
  return [(folder+'/'+name,subprocess.check_output(['git','show',f'{ref}:{folder}/{name}'],cwd=ROOT,text=True)) for name in names if name.endswith('.tf')]
 return [(str(p.relative_to(ROOT)),p.read_text()) for p in sorted((ROOT/folder).glob('*.tf'))]


def root_attributes(body):
 """Read attributes at the formatted block's first indentation level.

 This repository stores terraform-fmt formatted HCL. Nested dynamic-block
 for_each expressions must never be mistaken for a resource creation gate.
 Values retain their complete multiline source expression in the inventory.
 """
 matches=list(re.finditer(r'^  ([A-Za-z_][A-Za-z0-9_]*)\s*=\s*',body,re.M))
 attrs={}
 for i,m in enumerate(matches):
  end=matches[i+1].start() if i+1<len(matches) else len(body)
  value=body[m.end():end]
  block=re.search(r'^  [A-Za-z_][A-Za-z0-9_]*(?:\s+"[^"]+")?\s*\{',value,re.M)
  if block:value=value[:block.start()]
  attrs[m[1]]=value.strip()
 return attrs


def declaration_body(src,start):
 # The first column-zero close is the end of a terraform-fmt root block.
 end=re.search(r'^}',src[start:],re.M)
 if end is None:raise RuntimeError('Unclosed formatted Terraform root block')
 return src[start:start+end.start()]


def terraform(folder,ref=None,prefix='',stack=()):
 if (folder,ref) in stack: raise RuntimeError('Recursive Terraform module source')
 entries=[]; lookups=[]; sources=[]
 for path,src in read_sources(folder,ref):
  sources.append({'path':path,'revision':ref or 'working-tree','sha256':hashlib.sha256(src.encode()).hexdigest()})
  matches=list(DECL.finditer(src))
  for i,m in enumerate(matches):
   body=declaration_body(src,m.end())
   attrs=root_attributes(body)
   if m[1]=='module':
    source=re.search(r'^\s*source\s*=\s*"([^"]+)"',body,re.M)
    if not source: raise RuntimeError(f'Module source missing: {path}:{m[2]}')
    pin=re.search(r'//((?:modules|blueprints)/[^?]+)\?ref=([A-Za-z0-9_.-]+)$',source[1])
    if not pin: raise RuntimeError(f'Unresolved module source: {source[1]}')
    child=terraform(pin[1],pin[2],prefix+'module.'+m[2]+'.',stack+((folder,ref),))
    for e in child[0]+child[1]:
     e.setdefault('module_inputs',[]).append(prefix+'module.'+m[2]+' (see pinned call-site inputs)')
     e.setdefault('module_context',[]).append({
      'address':prefix+'module.'+m[2], 'source':source[1],
      'call_site':path,'call_site_revision':ref or 'working-tree',
      'creation_gate':{key:attrs[key] for key in ('count','for_each') if key in attrs},
      'enablement_inputs':{key:value for key,value in attrs.items() if key.startswith(('enable_','create_'))},
     })
    entries+=child[0]; lookups+=child[1]; sources+=child[2]
    continue
   typ,name=m[2],m[3]
   cloud='OCI' if typ.startswith('oci_') else 'GCP' if typ.startswith('google_') else 'AWS' if typ.startswith('aws_') else 'Azure' if typ.startswith('azurerm_') else 'Contracts'
   gate=next(((key,attrs[key]) for key in ('count','for_each') if key in attrs),None)
   e={'cloud':cloud,'kind':m[1],'address':prefix+typ+'.'+name,'type':typ,'symbol':name,'source':path,'revision':ref or 'working-tree','condition':(gate[0]+' = '+gate[1].splitlines()[0]) if gate else 'Unconditional declaration; module-level gates/inputs may still apply.',
      'creation_expression':{gate[0]:gate[1]} if gate else {}}
   (lookups if m[1]=='data' else entries).append(e)
 return entries,lookups,sources


def external(folder):
 entries=[]; sources=[]
 for p in sorted((ROOT/folder).glob('*/main.bicep')):
  src=p.read_text(); sources.append({'path':str(p.relative_to(ROOT)),'sha256':hashlib.sha256(src.encode()).hexdigest()})
  matches=list(re.finditer(r"^resource\s+(\w+)\s+'([^']+)'\s*=\s*([^\n]*)",src,re.M))
  for m in matches:
   gate=m[3].strip()
   entries.append({'cloud':'Azure','kind':'resource','address':m[1],'symbol':m[1],'type':m[2].split('@')[0],'source':str(p.relative_to(ROOT)),'revision':'working-tree','condition':gate if gate!='{' else 'Unconditional declaration in separately deployed Bicep template.'})
 for p in sorted((ROOT/folder).glob('*/main.yaml')):
  src=p.read_text(); sources.append({'path':str(p.relative_to(ROOT)),'sha256':hashlib.sha256(src.encode()).hexdigest()})
  section=src.split('\nResources:\n',1)[1].split('\nOutputs:',1)[0]
  matches=list(re.finditer(r'^  (\w+):\n    Type:\s*([^\n]+)',section,re.M))
  for i,m in enumerate(matches):
   body=section[m.end():matches[i+1].start() if i+1<len(matches) else len(section)]
   gate=re.search(r'^    Condition:\s*([^\n]+)',body,re.M)
   entries.append({'cloud':'AWS','kind':'resource','address':m[1],'symbol':m[1],'type':m[2].strip(),'source':str(p.relative_to(ROOT)),'revision':'working-tree','condition':'Condition: '+gate[1] if gate else 'Unconditional declaration in separately deployed CloudFormation template.'})
 return entries,sources


def wrapped(value,width=74):
 return '\n'.join(textwrap.wrap(value,width,break_long_words=True,break_on_hyphens=False))


def render_map(slug,cloud,entries,lookups,render,page_number=1):
 columns=3; width=820; step=850; row_height=220
 rows=(len(entries)+columns-1)//columns
 d=base.Diagram(toolkit=base.TOOLKIT,title=cloud+' resource declarations')
 d.text(cloud+' resources | '+slug.split('/')[-1]+(f' | Page {page_number}' if page_number>1 else ''),20,10,2540,45,size=25,bold=True)
 d.text('Complete declaration map / paired with architecture.png for topology / Source review 2026-10-28',20,65,2540,30,size=13)
 group=d.group('thirdparty' if cloud in ('Azure','AWS','GCP') else 'other',cloud+' / source-declared resources; conditional declarations remain visible',20,135,2560,70+rows*row_height)
 for i,e in enumerate(entries):
  x=20+(i%columns)*step; y=60+(i//columns)*row_height
  card=d.group('component','',x,y,width,195,parent=group)
  icon=ICONS.get(e['type']) if cloud=='OCI' else None
  if icon: d.icon(icon,55,90,parent=card,size=42,label='')
  vendor_icon=cloud_icons.icon(d,e['type'],55,90,parent=card,size=48)
  has_icon=bool(icon or vendor_icon)
  tx=100 if has_icon else 20; tw=width-tx-20
  gates=e.get('creation_expression',{})
  condition='; '.join(key+' = '+' '.join(value.split()) for key,value in gates.items()) if gates else e['condition']
  text=wrapped(e['address'],68 if has_icon else 79)+'\n'+wrapped(e['type'],68 if has_icon else 79)+'\n'+wrapped(condition,68 if has_icon else 79)
  d.text(text,tx,20,tw,155,parent=card,size=12)
  suffix=f'-{page_number:02}' if page_number>1 else ''
  e['diagram']={'file':cloud.lower()+'-resources'+suffix+'.drawio','page_name':cloud+' resources'+(f' {page_number}' if page_number>1 else ''),'node_id':card.id,'source_symbol':e['symbol'],'provider_icon':e['type'] if vendor_icon else None,'oci_icon':icon}
 y=group.y+group.h+35
 lookup_names=', '.join(e['address'] for e in lookups if e['cloud']==cloud)
 notes='Counts are declarations, not deployed instances. for_each and Bicep collections expand from inputs; gates retain their source expressions.\nPinned-module declarations use the module call-site inputs; the overview explains default enablement. Companion templates deploy separately.\nResource cards enumerate coverage only; card order does not imply dependency or traffic. IAM, DNS, circuits and workloads are not inferred beyond source.'
 if lookup_names: notes+='\nRead-only data lookups (not created resources): '+wrapped(lookup_names,160)
 note_height=max(130,40+20*len(notes.splitlines()))
 d.box(notes,20,y,2560,note_height,kind='note')
 warnings=d.check()
 if warnings: raise RuntimeError(str(warnings))
 suffix=f'-{page_number:02}' if page_number>1 else ''
 path=ROOT/'blueprints'/slug/'architecture'/ (cloud.lower()+'-resources'+suffix+'.drawio')
 d.save(str(path))
 if render and not d.render(str(path.with_suffix('.png')),scale=1.5): raise RuntimeError('PNG export failed')
 with path.open('a') as stream: stream.write('\n')
 return {'file':path.name,'page_name':entries[0]['diagram']['page_name'],'declarations':len(entries)}


def input_references(folder):
 """Document existing-resource ID inputs without reading private tfvars/state."""
 refs=[]
 for path,src in read_sources(folder):
  for m in re.finditer(r'^variable "([^"]+)"\s*\{',src,re.M):
   name=m[1]
   if not re.search(r'(_ids?|_ocids?)$',name):continue
   if name in ('tenancy_ocid','current_user_ocid'):continue
   attrs=root_attributes(declaration_body(src,m.end()))
   refs.append({'address':'var.'+name,'source':path,'description':attrs.get('description','').strip('"'),
                'default_expression':attrs.get('default','REQUIRED'),'type_expression':attrs.get('type','unknown'),
                'scope':'Input reference; may reuse an existing resource or override a created-resource selection. Not a created resource.'})
 return refs


def render_inputs(slug,refs,render):
 d=base.Diagram(toolkit=base.TOOLKIT,title='Existing resource references')
 d.text('Existing resources and overrides | '+slug.split('/')[-1],20,10,2540,45,size=25,bold=True)
 d.text('Source-declared identifier inputs / not created resources / no live inventory or private tfvars read',20,65,2540,30,size=13)
 rows=(len(refs)+2)//3
 for i,e in enumerate(refs):
  x=20+(i%3)*850;y=140+(i//3)*230
  card=d.group('optional','',x,y,820,205)
  label=e['address']+'\n'+wrapped(e['description'],85)+'\nDefault expression: '+wrapped(e['default_expression'],85)
  d.text(label,20,15,780,175,parent=card,size=12)
  e['diagram']={'file':'existing-resources.drawio','page_name':'Existing resources / inputs','node_id':card.id}
 d.box('These inputs identify separately managed resources or override a default selection. The overview and module call-site decide their use.\nNull/empty defaults do not prove that an external resource exists. Input names and defaults are source contracts, not discovered cloud inventory.\nCollection inputs can contain further resource references; consult their source schemas and the overview prerequisites. No ownership adoption is implied.',20,165+rows*230,2540,130,kind='note')
 if d.check():raise RuntimeError(str(d.check()))
 path=ROOT/'blueprints'/slug/'architecture/existing-resources.drawio'
 d.save(str(path))
 if render and not d.render(str(path.with_suffix('.png')),scale=1.5):raise RuntimeError('Input-reference PNG export failed')
 with path.open('a') as stream:stream.write('\n')
 return {'file':path.name,'page_name':'Existing resources / inputs','references':len(refs)}


def main():
 parser=argparse.ArgumentParser(description=__doc__)
 parser.add_argument('--render',action='store_true'); parser.add_argument('--blueprint',action='append'); parser.add_argument('--check',action='store_true')
 parser.add_argument('--first-39',action='store_true',help='Review the fixed 39-overview baseline from first-39-review.json')
 args=parser.parse_args()
 if args.first_39 and args.blueprint:parser.error('Choose --first-39 or --blueprint')
 selected=json.loads(Path(__file__).with_name('first-39-review.json').read_text())['blueprints'] if args.first_39 else args.blueprint or DEFAULTS
 for slug in selected:
  folder='blueprints/'+slug
  resources,lookups,sources=terraform(folder)
  remote,remote_sources=external(folder); resources+=remote; sources+=remote_sources
  for template in sorted((ROOT/folder).glob('*/main.tf')):
   if template.parent.name.lower() in ('azure','aws','gcp'):
    r,l,s=terraform(str(template.parent.relative_to(ROOT)))
    resources+=r; lookups+=l; sources+=s
  addresses=[(e['cloud'],e['address']) for e in resources]
  if len(addresses)!=len(set(addresses)): raise RuntimeError('Duplicate resource address')
  inventory_path=ROOT/folder/'architecture/resource-inventory.json'
  refs=input_references(folder)
  if args.check:
   saved=json.loads(inventory_path.read_text())
   current={(e['cloud'],e['address'],e['type'],e['condition'],e['revision']) for e in resources}
   recorded={(e['cloud'],e['address'],e['type'],e['condition'],e['revision']) for e in saved['resources']}
   if current!=recorded or sources!=saved['source_files']:
    raise RuntimeError('Inventory is stale or incomplete: '+slug)
   if saved.get('schema_version',1)>=2:
    actual=[{k:v for k,v in entry.items() if k!='diagram'} for entry in saved['resources']]
    if actual!=resources:raise RuntimeError('Creation expression or module context is stale: '+slug)
    if saved['data_lookups']!=lookups:raise RuntimeError('Read-only lookup inventory is stale: '+slug)
   pages={p.get('name'):p for p in ET.parse(inventory_path.parent/'architecture.drawio').getroot().findall('diagram')}
   for e in saved['resources']:
    mapping=e['diagram']; path=inventory_path.parent/mapping['file']
    nodes={c.get('id'):c for c in ET.parse(path).findall('.//mxCell')}
    if mapping['node_id'] not in nodes: raise RuntimeError('Resource node missing: '+e['address'])
    labels=''.join(n.get('value','') for n in nodes.values() if n.get('parent')==mapping['node_id'])
    normalized=re.sub(r'\s+','',re.sub(r'<[^>]+>','',html.unescape(labels)))
    if e['address'] not in normalized: raise RuntimeError('Resource label missing: '+e['address'])
    page=pages.get(mapping.get('page_name',e['cloud']+' resources'))
    if page is None: raise RuntimeError('Main document resource page missing')
    page_nodes={c.get('id'):c for c in page.findall('.//mxCell')}
    if mapping['node_id'] not in page_nodes: raise RuntimeError('Main document resource node missing')
    main_labels=''.join(n.get('value','') for n in page_nodes.values() if n.get('parent')==mapping['node_id'])
    if re.sub(r'\s+','',re.sub(r'<[^>]+>','',html.unescape(main_labels)))!=normalized:raise RuntimeError('Main resource card differs from companion')
    descendants=[n for n in nodes.values() if n.get('parent')==mapping['node_id']]
    expected_icon=e['type'] if cloud_icons.available(e['type']) else None
    if mapping.get('provider_icon')!=expected_icon: raise RuntimeError('Provider icon mapping stale')
    if 'oci_icon' in mapping and mapping['oci_icon']!=ICONS.get(e['type']):raise RuntimeError('OCI icon mapping stale')
    if expected_icon:
     glyphs=[n for n in nodes.values() if n.get('parent') in {child.get('id') for child in descendants}]
     if not glyphs: raise RuntimeError('Provider glyph missing')
     for glyph in glyphs:
      style=glyph.get('style','')
      if e['cloud']=='Azure':
       encoded=re.search(r'image=data:image/svg\+xml,([^;]+);',style)
       if not encoded: raise RuntimeError('Azure SVG embedding invalid')
       ET.fromstring(base64.b64decode(encoded[1]))
      elif 'shape=mxgraph.'+('aws4.' if e['cloud']=='AWS' else 'gcp2.') not in style:
       raise RuntimeError('Wrong provider stencil')
    png=path.with_suffix('.png').read_bytes()
    if png[:8]!=b'\x89PNG\r\n\x1a\n': raise RuntimeError('PNG missing or invalid')
   if 'input_references' in saved:
    actual=[{k:v for k,v in entry.items() if k!='diagram'} for entry in saved['input_references']]
    if actual!=refs:raise RuntimeError('Input-reference inventory is stale')
    for e in saved['input_references']:
     mapping=e['diagram'];page=pages.get(mapping['page_name'])
     if page is None:raise RuntimeError('Existing resource references page missing')
     cells={c.get('id'):c for c in page.findall('.//mxCell')}
     if mapping['node_id'] not in cells:raise RuntimeError('Input reference card missing')
     labels=''.join(n.get('value','') for n in cells.values() if n.get('parent')==mapping['node_id'])
     if e['address'] not in html.unescape(labels):raise RuntimeError('Input reference label missing')
     if not (inventory_path.parent/'existing-resources.png').read_bytes().startswith(b'\x89PNG\r\n\x1a\n'):raise RuntimeError('Existing resources PNG missing')
   if args.first_39 and ('input_references' not in saved or 'resource_pages' not in saved):raise RuntimeError('First-39 review metadata missing')
   print(slug, str(len(resources))+' declarations checked against source and diagram nodes',flush=True)
   continue
  counts={};resource_pages=[]
  for cloud in sorted({e['cloud'] for e in resources}):
   entries=[e for e in resources if e['cloud']==cloud];counts[cloud]=len(entries)
   for start in range(0,len(entries),18):
    resource_pages.append(render_map(slug,cloud,entries[start:start+18],lookups,args.render,start//18+1))
  input_page=render_inputs(slug,refs,args.render) if refs else None
  if not all('diagram' in e for e in resources): raise RuntimeError('Resource missing diagram mapping')
  inventory={'schema_version':2,'blueprint':slug,'review_date':'2026-10-28','scope':'Root resource declarations, transitive pinned same-repository Terraform modules, and separately deployed companion templates. Not a resolved plan or deployment inventory.','counts_by_cloud':counts,'resources':resources,'resource_pages':resource_pages,'input_references':refs,'input_page':input_page,'data_lookups':lookups,'source_files':sources}
  inventory_path.write_text(json.dumps(inventory,indent=2)+'\n')
  # Rebuild the native document as overview + generated resource-detail pages.
  # Layouts and all shapes are authored through the skill API, not hand-edited XML.
  main_path=inventory_path.parent/'architecture.drawio'
  existing=ET.parse(main_path).getroot()
  combined=ET.Element('mxfile',host='ocidraw',type='device')
  combined.append(copy.deepcopy(existing.find('diagram')))
  for idx,meta in enumerate(resource_pages+([input_page] if input_page else [])):
   page=copy.deepcopy(ET.parse(inventory_path.parent/meta['file']).getroot().find('diagram'))
   page.set('id','resource-detail-'+str(idx)); page.set('name',meta['page_name'])
   combined.append(page)
  ET.ElementTree(combined).write(main_path,encoding='unicode')
  with main_path.open('a') as stream: stream.write('\n')
  print(slug,counts,'all declarations mapped',flush=True)


if __name__=='__main__': main()
