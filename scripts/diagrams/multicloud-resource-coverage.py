#!/usr/bin/env python3
"""Resource-detail companions for cross-cloud architecture overviews.

Enumerates resource declarations (not resolved instance counts) in root Terraform,
transitive pinned local-repository modules and companion Bicep/CloudFormation.
Creates one editable/PNG resource map per cloud plus an auditable JSON inventory.
Overview diagrams remain the topology view. Run --render for PNG export.
"""
import argparse
import hashlib
import importlib.util
import json
import html
from pathlib import Path
import re
import subprocess
import textwrap
import copy
import xml.etree.ElementTree as ET

ROOT=Path(__file__).resolve().parents[2]
spec=importlib.util.spec_from_file_location('networking_batch_02',Path(__file__).with_name('networking-batch-02.py'))
base=importlib.util.module_from_spec(spec); spec.loader.exec_module(base)
DEFAULTS=[
 'networking/hub-spoke-with-azure-vwan-expressroute',
 'networking/azure-vwan-oci-drg-transit',
 'networking/azure-oci-dual-connectivity',
 'networking/aws-oci-hybrid-network-backbone',
 'disaster-recovery/azure-oci-cross-cloud-dr',
]
DECL=re.compile(r'^(resource|data|module)\s+"([^"]+)"(?:\s+"([^"]+)")?\s*\{',re.M)
ICONS={
 'oci_core_vcn':'VCN (Region Identifier)','oci_core_subnet':None,
 'oci_core_drg':'DRG','oci_core_drg_attachment':None,
 'oci_core_internet_gateway':'Internet Gateway','oci_core_nat_gateway':'NAT Gateway',
 'oci_core_service_gateway':'Service Gateway','oci_core_route_table':'Route Table',
 'oci_core_security_list':'Security Lists','oci_core_cpe':'Customer Premises Equipment',
 'oci_core_ipsec':None,'oci_core_virtual_circuit':None,
 'oci_objectstorage_bucket':'OCI Object Storage','oci_ons_notification_topic':'Notifications',
}


def read_sources(folder,ref=None):
 if ref:
  names=subprocess.check_output(['git','ls-tree','--name-only',f'{ref}:{folder}'],cwd=ROOT,text=True).splitlines()
  return [(folder+'/'+name,subprocess.check_output(['git','show',f'{ref}:{folder}/{name}'],cwd=ROOT,text=True)) for name in names if name.endswith('.tf')]
 return [(str(p.relative_to(ROOT)),p.read_text()) for p in sorted((ROOT/folder).glob('*.tf'))]


def terraform(folder,ref=None,prefix='',stack=()):
 if (folder,ref) in stack: raise RuntimeError('Recursive Terraform module source')
 entries=[]; lookups=[]; sources=[]
 for path,src in read_sources(folder,ref):
  sources.append({'path':path,'revision':ref or 'working-tree','sha256':hashlib.sha256(src.encode()).hexdigest()})
  matches=list(DECL.finditer(src))
  for i,m in enumerate(matches):
   body=src[m.end():matches[i+1].start() if i+1<len(matches) else len(src)]
   if m[1]=='module':
    source=re.search(r'^\s*source\s*=\s*"([^"]+)"',body,re.M)
    if not source: raise RuntimeError(f'Module source missing: {path}:{m[2]}')
    pin=re.search(r'//((?:modules|blueprints)/[^?]+)\?ref=([A-Za-z0-9_.-]+)$',source[1])
    if not pin: raise RuntimeError(f'Unresolved module source: {source[1]}')
    child=terraform(pin[1],pin[2],prefix+'module.'+m[2]+'.',stack+((folder,ref),))
    for e in child[0]+child[1]:
     e.setdefault('module_inputs',[]).append(prefix+'module.'+m[2]+' (see pinned call-site inputs)')
    entries+=child[0]; lookups+=child[1]; sources+=child[2]
    continue
   typ,name=m[2],m[3]
   cloud='OCI' if typ.startswith('oci_') else 'GCP' if typ.startswith('google_') else 'AWS' if typ.startswith('aws_') else 'Azure' if typ.startswith('azurerm_') else 'Contracts'
   gate=re.search(r'^\s*(count|for_each)\s*=\s*([^\n]+)',body,re.M)
   e={'cloud':cloud,'kind':m[1],'address':prefix+typ+'.'+name,'type':typ,'symbol':name,'source':path,'revision':ref or 'working-tree','condition':(gate[1]+' = '+gate[2].strip()) if gate else 'Unconditional declaration; module-level gates/inputs may still apply.'}
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


def render_map(slug,cloud,entries,lookups,render):
 columns=3; width=820; step=850; row_height=220
 rows=(len(entries)+columns-1)//columns
 d=base.Diagram(toolkit=base.TOOLKIT,title=cloud+' resource declarations')
 d.text(cloud+' resources | '+slug.split('/')[-1],20,10,2540,45,size=25,bold=True)
 d.text('Complete declaration map / paired with architecture.png for topology / Source review 2026-10-28',20,65,2540,30,size=13)
 group=d.group('thirdparty' if cloud in ('Azure','AWS','GCP') else 'other',cloud+' / source-declared resources; conditional declarations remain visible',20,135,2560,70+rows*row_height)
 for i,e in enumerate(entries):
  x=20+(i%columns)*step; y=60+(i//columns)*row_height
  card=d.group('component','',x,y,width,195,parent=group)
  icon=ICONS.get(e['type']) if cloud=='OCI' else None
  if icon: d.icon(icon,55,90,parent=card,size=42,label='')
  tx=100 if icon else 20; tw=width-tx-20
  text=wrapped(e['address'],68 if icon else 79)+'\n'+wrapped(e['type'],68 if icon else 79)+'\n'+wrapped(e['condition'],68 if icon else 79)
  d.text(text,tx,20,tw,155,parent=card,size=12)
  e['diagram']={'file':cloud.lower()+'-resources.drawio','node_id':card.id,'source_symbol':e['symbol']}
 y=group.y+group.h+35
 lookup_names=', '.join(e['address'] for e in lookups if e['cloud']==cloud)
 notes='Counts are declarations, not deployed instances. for_each and Bicep collections expand from inputs; gates retain their source expressions.\nPinned-module declarations use the module call-site inputs; the overview explains default enablement. Companion templates deploy separately.\nResource cards enumerate coverage only; card order does not imply dependency or traffic. IAM, DNS, circuits and workloads are not inferred beyond source.'
 if lookup_names: notes+='\nRead-only data lookups (not created resources): '+wrapped(lookup_names,160)
 note_height=max(130,40+20*len(notes.splitlines()))
 d.box(notes,20,y,2560,note_height,kind='note')
 warnings=d.check()
 if warnings: raise RuntimeError(str(warnings))
 path=ROOT/'blueprints'/slug/'architecture'/ (cloud.lower()+'-resources.drawio')
 d.save(str(path))
 if render and not d.render(str(path.with_suffix('.png')),scale=1.5): raise RuntimeError('PNG export failed')
 with path.open('a') as stream: stream.write('\n')
 return len(entries)


def main():
 parser=argparse.ArgumentParser(description=__doc__)
 parser.add_argument('--render',action='store_true'); parser.add_argument('--blueprint',action='append'); parser.add_argument('--check',action='store_true')
 args=parser.parse_args()
 for slug in args.blueprint or DEFAULTS:
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
  if args.check:
   saved=json.loads(inventory_path.read_text())
   current={(e['cloud'],e['address'],e['type'],e['condition'],e['revision']) for e in resources}
   recorded={(e['cloud'],e['address'],e['type'],e['condition'],e['revision']) for e in saved['resources']}
   if current!=recorded or sources!=saved['source_files']:
    raise RuntimeError('Inventory is stale or incomplete: '+slug)
   for e in saved['resources']:
    mapping=e['diagram']; path=inventory_path.parent/mapping['file']
    nodes={c.get('id'):c for c in ET.parse(path).findall('.//mxCell')}
    if mapping['node_id'] not in nodes: raise RuntimeError('Resource node missing: '+e['address'])
    labels=''.join(n.get('value','') for n in nodes.values() if n.get('parent')==mapping['node_id'])
    normalized=re.sub(r'\s+','',re.sub(r'<[^>]+>','',html.unescape(labels)))
    if e['address'] not in normalized: raise RuntimeError('Resource label missing: '+e['address'])
    png=path.with_suffix('.png').read_bytes()
    if png[:8]!=b'\x89PNG\r\n\x1a\n': raise RuntimeError('PNG missing or invalid')
   print(slug, str(len(resources))+' declarations checked against source and diagram nodes',flush=True)
   continue
  counts={}
  for cloud in sorted({e['cloud'] for e in resources}):
   counts[cloud]=render_map(slug,cloud,[e for e in resources if e['cloud']==cloud],lookups,args.render)
  if not all('diagram' in e for e in resources): raise RuntimeError('Resource missing diagram mapping')
  inventory={'schema_version':1,'blueprint':slug,'review_date':'2026-10-28','scope':'Root resource declarations, transitive pinned same-repository Terraform modules, and separately deployed companion templates. Not a resolved plan or deployment inventory.','counts_by_cloud':counts,'resources':resources,'data_lookups':lookups,'source_files':sources}
  inventory_path.write_text(json.dumps(inventory,indent=2)+'\n')
  # Rebuild the native document as overview + generated resource-detail pages.
  # Layouts and all shapes are authored through the skill API, not hand-edited XML.
  main_path=inventory_path.parent/'architecture.drawio'
  existing=ET.parse(main_path).getroot()
  combined=ET.Element('mxfile',host='ocidraw',type='device')
  combined.append(copy.deepcopy(existing.find('diagram')))
  for cloud in sorted(counts):
   page=copy.deepcopy(ET.parse(inventory_path.parent/(cloud.lower()+'-resources.drawio')).getroot().find('diagram'))
   page.set('id','resources-'+cloud.lower()); page.set('name',cloud+' resources')
   combined.append(page)
  ET.ElementTree(combined).write(main_path,encoding='unicode')
  with main_path.open('a') as stream: stream.write('\n')
  print(slug,counts,'all declarations mapped',flush=True)


if __name__=='__main__': main()
