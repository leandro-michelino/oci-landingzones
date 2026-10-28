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
 m=load('interconnect-batch-01')
 for i,slug in enumerate(m.ITEMS):yield slug,m.build(bool(i))

def cloud_boundary(node):
 while node.parent is not None:node=node.parent
 if node.kind=='group:region' and node.label.startswith('OCI'):return 'OCI'
 if node.kind=='group:thirdparty':
  for prefix,cloud in [('AWS','AWS'),('Azure','Azure'),('Google','GCP')]:
   if node.label.startswith(prefix):return cloud
 return None

def main():
 parser=argparse.ArgumentParser(description=__doc__)
 parser.add_argument('--render-updated',action='store_true')
 parser.add_argument('--write-report',action='store_true')
 args=parser.parse_args();records=[]
 for slug,d in diagrams():
  folder=ROOT/'blueprints'/slug/'architecture';path=folder/'architecture.drawio'
  warnings=d.check()
  if warnings:raise RuntimeError((slug,warnings))
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
  foreign=set(inv['counts_by_cloud']) & {'AWS','Azure','GCP'}
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
 report={'review_date':'2026-10-28','scope':'Static connection/geometry review of published overviews; no runtime verification. Detail/reference maps intentionally have no inferred flows.',
 'checks':['Every overview has relationship lines','Cross-cloud source inventories have an explicit OCI bridge','Layout warnings empty','Overview matches authoring script','Every native page has unique IDs and valid references'],
 'overview_count':len(records),'cross_cloud_overviews':sum(bool(r['cross_cloud_bridges']) for r in records),'blueprints':records}
 if args.write_report:(ROOT/'docs/diagrams/connection-review.json').write_text(json.dumps(report,indent=2)+'\n')
 print(f"{len(records)} overviews passed; {report['cross_cloud_overviews']} cross-cloud overviews have explicit OCI bridges.")
if __name__=='__main__':main()
