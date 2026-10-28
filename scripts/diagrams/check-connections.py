#!/usr/bin/env python3
"""Check every published overview for connectors and explicit cross-cloud bridges.

Detail maps enumerate declarations, not topology, and are deliberately excluded.
Reconstruct diagrams with their authoring scripts and the installed OCI skill.
"""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess
import xml.etree.ElementTree as ET
ROOT=Path(__file__).resolve().parents[2]
UPDATED={
 'data-platform/opensearch','data-platform/mysql-heatwave',
 'data-platform/oci-aws-mysql-heatwave-dr','ai/genai-private','ai/ai-services',
 'compliance/security-posture','disaster-recovery/azure-oci-cross-cloud-dr',
 'disaster-recovery/aws-oci-cross-cloud-dr',
 'networking/hub-spoke-with-azure-vwan-expressroute',
}
def load(name):
 spec=importlib.util.spec_from_file_location(name,Path(__file__).with_name(name+'.py'))
 mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod);return mod

def diagrams():
 yield from load('review-first-39').overviews()
 m=load('data-dr-batch-01')
 for i,(slug,title,kind) in enumerate(m.ITEMS,16):
  yield slug,{'aws':m.aws,'adb':lambda t,n:m.database(t,n),'postgres':lambda t,n:m.database(t,n,True),'private':m.private,'apex':m.apex}[kind](title,i)
 m=load('data-ai-batch-01')
 for i,(slug,title,kind) in enumerate(m.ITEMS,21):
  yield slug,{'search':lambda t,n:m.database(t,n,True),'mysql':m.database,'dr':m.dr,'genai':m.genai,'ai':m.ai}[kind](title,i)
 m=load('ai-batch-02')
 for i,(slug,title,kind) in enumerate(m.ITEMS,26):yield slug,getattr(m,kind)(title,i)
 m=load('ai-industry-batch-03')
 for i,(slug,title,kind) in enumerate(m.ITEMS,31):yield slug,getattr(m,kind)(title,i)
 m=load('compute-extensions-batch-01')
 for i,(slug,title,kind) in enumerate(m.ITEMS,36):yield slug,getattr(m,kind)(title,i)
 m=load('extensions-batch-02')
 for i,(slug,title,kind) in enumerate(m.ITEMS,41):yield slug,getattr(m,kind)(title,i)
 m=load('extensions-batch-03')
 for i,(slug,title,kind) in enumerate(m.ITEMS,46):yield slug,getattr(m,kind)(title,i)
 m=load('extensions-data-batch-04')
 for i,(slug,title,kind) in enumerate(m.ITEMS,51):yield slug,getattr(m,kind)(title,i)
 m=load('interconnect-batch-01')
 for i,slug in enumerate(m.ITEMS):yield slug,m.build(bool(i))
 m=load('vmware-hybrid')
 for i,slug in enumerate(m.ITEMS):yield slug,m.build(i)
 m=load('ocvs')
 yield m.SLUG,m.build()
 m=load('healthcare-platform')
 yield m.SLUG,m.build()
 m=load('healthcare-fhir-integration')
 yield m.SLUG,m.build()

def cloud_boundary(node):
 while node.parent is not None:node=node.parent
 if node.kind=='group:region' and node.label.startswith('OCI'):return 'OCI'
 if node.kind=='group:thirdparty':
  for prefix,cloud in [('AWS','AWS'),('Azure','Azure'),('Google','GCP'),('Cloudflare','Cloudflare')]:
   if node.label.startswith(prefix):return cloud
 return None

def relationships(d):
 """Stable review contract: detect endpoint, direction, label and path changes."""
 cells=[c for c in ET.fromstring(d.xml()).findall('.//mxCell') if c.get('edge')=='1']
 assert len(cells)==len(d.edge_meta)
 result=[]
 for c,e in zip(cells,d.edge_meta):
  style=dict(v.split('=',1) for v in c.get('style','').split(';') if '=' in v)
  result.append({'source':e['a'].label or e['a'].name,'target':e['b'].label or e['b'].name,
   'source_kind':e['a'].kind,'target_kind':e['b'].kind,'label':e['label'],
   'dashed':style.get('dashed')=='1','start_arrow':style.get('startArrow','none'),
   'end_arrow':style.get('endArrow','none'),'exit':e['exit'],'entry':e['entry'],
   'waypoints':e['waypoints'],'straight':e['straight']})
 return result

def verify_sources(sources,verified):
 for source in sources:
  revision=source.get('revision','working-tree')
  key=(source['path'],revision,source['sha256'])
  if key in verified:continue
  content=(ROOT/source['path']).read_bytes() if revision=='working-tree' else subprocess.check_output(
   ['git','show',revision+':'+source['path']],cwd=ROOT)
  assert hashlib.sha256(content).hexdigest()==source['sha256'],('Source changed since review',key[:2])
  verified.add(key)

def semantic_checks(slug,d):
 for e in d.edge_meta:
  a,b=e['a'],e['b']
  if b.name=='Route Table':
   assert a.kind.startswith('group:'),(slug,'Route-table binding must originate at subnet/group',a.label)
  if 'attached_views' in e['label']:
   assert a.label.startswith('Private DNS view'),(slug,'Resolver must bind the view, not the zone')
 if slug.startswith('operating-entity'):
  bindings=[e for e in d.edge_meta if e['a'].name=='Policies']
  assert bindings and all(e['b'].kind=='group:compartment' and 'created root compartment' in e['b'].label for e in bindings),slug
 if slug.startswith('networking/') and slug.endswith('interconnect') and slug!='networking/hub-spoke-with-multicloud-interconnect':
  assert any(e['a'].kind=='group:subnet' and e['b'].name=='Route Table' for e in d.edge_meta),slug
 if slug=='compliance/zero-trust':
  assert any(e['a'].name=='NAT Gateway' and e['b'].name=='Internet' for e in d.edge_meta),slug

def main():
 parser=argparse.ArgumentParser(description=__doc__)
 parser.add_argument('--render-updated',action='store_true')
 parser.add_argument('--write-report',action='store_true')
 parser.add_argument('--record-reviewed-connectors',action='store_true',help='Replace the review contract only after source and PNG review')
 args=parser.parse_args();records=[];contracts={};native_files=set();native_pages=0;verified_sources=set()
 for slug,d in diagrams():
  folder=ROOT/'blueprints'/slug/'architecture';path=folder/'architecture.drawio'
  warnings=d.check()+d._crossings([n for n in d.nodes if n.kind=='text'])
  if warnings:raise RuntimeError((slug,warnings))
  semantic_checks(slug,d)
  if not d.edge_meta:raise RuntimeError('Overview has no relationship lines: '+slug)
  if args.render_updated and slug in UPDATED:
   d.save(str(path));assert d.render(str(path.with_suffix('.png')),scale=1.5)
   with path.open('a') as stream:stream.write('\n')
   print('Rendered',slug,flush=True)
  if args.render_updated:continue
  root=ET.parse(path).getroot();page=root.find('diagram')
  if ET.tostring(page)!=ET.tostring(ET.fromstring(d.xml()).find('diagram')):
   raise RuntimeError('Overview differs from authoring script: '+slug)
  for native_page in root.findall('diagram'):
   cells=native_page.findall('.//mxCell');ids=[c.get('id') for c in cells]
   assert len(ids)==len(set(ids)),slug
   for c in cells:
    for key in ('parent','source','target'):
     if c.get(key):assert c.get(key) in ids,(slug,key,c.get(key))
  inv=json.loads((folder/'resource-inventory.json').read_text())
  verify_sources(inv['source_files'],verified_sources)
  contracts[slug]={'relationships':relationships(d),'source_files':inv['source_files']}
  native_files.add(path)
  native_files.update(folder/p['file'] for p in inv['resource_pages'])
  if inv['input_page']:native_files.add(folder/inv['input_page']['file'])
  native_pages+=len(root.findall('diagram'))
  foreign=set(inv['counts_by_cloud']) & {'AWS','Azure','GCP','Cloudflare'}
  bridges=[]
  for edge in d.edge_meta:
   a,b=cloud_boundary(edge['a']),cloud_boundary(edge['b'])
   if a!=b and 'OCI' in (a,b) and (a in foreign or b in foreign):
    bridges.append({'source':edge['a'].id,'target':edge['b'].id,'label':edge['label'],'clouds':[a,b]})
  if foreign and not bridges:raise RuntimeError('External cloud has no explicit bridge to OCI: '+slug)
  png=path.with_suffix('.png').read_bytes();assert png.startswith(b'\x89PNG\r\n\x1a\n')
  records.append({'blueprint':slug,'connections':len(d.edge_meta),'cross_cloud_bridges':bridges,
    'overview_png_sha256':hashlib.sha256(png).hexdigest(),'layout_warnings':warnings})
 if args.render_updated:return
 actual=set(subprocess.check_output(['rg','--files','blueprints','-g','architecture.drawio','-g','!**/.terraform/**'],cwd=ROOT,text=True).splitlines())
 expected={'blueprints/'+r['blueprint']+'/architecture/architecture.drawio' for r in records}
 assert actual==expected,'Published overview coverage differs from authoring-script registry'
 conceptual=load('conceptual-three-tier').build()
 conceptual_path=ROOT/'docs/diagrams/oci-3tier-adb.drawio'
 assert not conceptual.check()+conceptual._crossings([n for n in conceptual.nodes if n.kind=='text'])
 assert ET.tostring(ET.parse(conceptual_path).getroot().find('diagram'))==ET.tostring(ET.fromstring(conceptual.xml()).find('diagram'))
 assert conceptual_path.with_suffix('.png').read_bytes().startswith(b'\x89PNG\r\n\x1a\n')
 native_files.add(conceptual_path)
 contracts['docs/diagrams/oci-3tier-adb']={'relationships':relationships(conceptual),'source_files':[],
  'scope':'Illustrative design; no source-backed deployment claim'}
 found={ROOT/p for p in subprocess.check_output(['rg','--files','-g','*.drawio','-g','!**/.terraform/**'],cwd=ROOT,text=True).splitlines()}
 assert found==native_files,('Native documents missing from review registry',found^native_files)
 for native in native_files:
  assert native.with_suffix('.png').read_bytes().startswith(b'\x89PNG\r\n\x1a\n'),native
  for page in ET.parse(native).getroot().findall('diagram'):
   cells=page.findall('.//mxCell');ids=[c.get('id') for c in cells]
   assert len(ids)==len(set(ids)),native
   for c in cells:
    for key in ('source','target','parent'):
     assert not c.get(key) or c.get(key) in ids,(native,key,c.get(key))
 contract_path=ROOT/'docs/diagrams/reviewed-connectors.json'
 normalized=json.loads(json.dumps(contracts))
 if args.record_reviewed_connectors:contract_path.write_text(json.dumps(normalized,indent=2)+'\n')
 assert contract_path.exists(),'Record the initial reviewed connector contract after inspecting source and PNGs'
 assert json.loads(contract_path.read_text())==normalized,'Connector/source changes require another semantic and visual review'
 report={'review_date':'2026-10-28','scope':'Static connection/geometry review of published overviews; no runtime verification. Detail/reference maps intentionally have no inferred flows.',
 'checks':['Every overview has relationship lines','Cross-cloud source inventories have an explicit OCI bridge','Icon and text crossing checks empty','Overview matches authoring script','Every native page has unique IDs and valid references','Reviewed endpoints, labels, arrows, paths and source hashes match contract','Subnet routing and DNS-view semantic regression checks'],
 'overview_count':len(records),'conceptual_overviews':1,'native_documents':len(native_files),
 'main_document_pages':native_pages+1,'connector_count':sum(r['connections'] for r in records)+len(conceptual.edge_meta),
 'cross_cloud_overviews':sum(bool(r['cross_cloud_bridges']) for r in records),'blueprints':records}
 if args.write_report:(ROOT/'docs/diagrams/connection-review.json').write_text(json.dumps(report,indent=2)+'\n')
 print(f"{len(records)} blueprint + 1 conceptual overviews passed; {report['connector_count']} reviewed connectors; {len(native_files)} native documents and PNGs; {report['cross_cloud_overviews']} explicit OCI/cloud bridges.")
if __name__=='__main__':main()
