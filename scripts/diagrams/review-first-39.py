#!/usr/bin/env python3
"""Review the fixed first-39 scope without provisioning or changing Terraform.

Checks every overview against its authoring script and the OCI skill's layout
checker. --write-report records the successful static review. Resource-page
checks are provided by multicloud-resource-coverage.py --first-39 --check.
"""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess
import xml.etree.ElementTree as ET
ROOT=Path(__file__).resolve().parents[2]
MANIFEST=Path(__file__).with_name('first-39-review.json')

def load(name):
 spec=importlib.util.spec_from_file_location(name,Path(__file__).with_name(name+'.py'))
 mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod);return mod

def overviews():
 batches=[('networking-batch-01',1),('networking-batch-02',6),('networking-batch-03',11),('networking-batch-04',16),('networking-batch-05',21),('foundation-batch-01',1),('foundation-batch-02',6),('compliance-dr-batch-01',11)]
 for name,start in batches:
  m=load(name)
  for index,entry in enumerate(m.ITEMS,start):
   slug,title=entry[:2];kind=entry[2]
   if name=='networking-batch-01':d=m.external(title,index) if index==5 else m.network(*entry,index)
   elif name=='networking-batch-02':d=m.build(title,kind,index)
   elif name=='networking-batch-03':
    d=m.base.build(title,'base',index,fortigate=kind=='fortigate',scope_note=m.NOTES[kind],subtitle=f'NETWORKING {index:02} / Official OCI Toolkit v24.2 / Default foundation + explicit extension scope');m.panel(d,kind)
   elif name=='networking-batch-04':d=m.dual(title,index) if kind=='dr' else m.shared(title,index,kind) if kind in ('tenancy','multi') else m.crosscloud(title,index,kind)
   elif name=='networking-batch-05':d=getattr(m,kind)(title,index)
   elif name=='foundation-batch-01':d=m.foundation(title,index,kind) if kind in ('core','level1','level2') else m.identity(title,index) if kind=='identity' else m.domain(title,index)
   elif name=='foundation-batch-02':d=m.domains(title,index) if kind=='domain' else m.scca(title,index) if kind=='scca' else m.entities(title,index,kind)
   else:d={'zero':m.zero,'health':m.health,'posture':m.posture,'fsdr':m.fsdr,'azure':m.azure}[kind](title,index)
   yield ('networking/'+slug if name.startswith('networking') else slug),d

def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--write-report',action='store_true');args=parser.parse_args()
 manifest=json.loads(MANIFEST.read_text());reviewed=[]
 for slug,d in overviews():
  warnings=d.check()
  if warnings:raise RuntimeError((slug,warnings))
  folder=ROOT/'blueprints'/slug/'architecture'
  actual=ET.parse(folder/'architecture.drawio').getroot().find('diagram')
  expected=ET.fromstring(d.xml()).find('diagram')
  if ET.tostring(actual)!=ET.tostring(expected):raise RuntimeError('Overview differs from its generator: '+slug)
  inv=json.loads((folder/'resource-inventory.json').read_text())
  pngs=[folder/'architecture.png']+[folder/Path(p['file']).with_suffix('.png') for p in inv['resource_pages']]
  if inv['input_page']:pngs.append(folder/'existing-resources.png')
  for path in pngs:
   if not path.read_bytes().startswith(b'\x89PNG\r\n\x1a\n'):raise RuntimeError('PNG missing: '+str(path))
  reviewed.append({'blueprint':slug,'overview_layout_warnings':warnings,'counts_by_cloud':inv['counts_by_cloud'],
    'resource_detail_pages':len(inv['resource_pages']),'existing_resource_inputs':len(inv['input_references']),
    'native_document_pages':len(ET.parse(folder/'architecture.drawio').getroot().findall('diagram')),
    'inventory_sha256':digest(folder/'resource-inventory.json'),
    'png_sha256':{str(p.relative_to(ROOT)):digest(p) for p in pngs}})
 if [r['blueprint'] for r in reviewed]!=manifest['blueprints']:raise RuntimeError('Review scope differs from fixed first-39 manifest')
 subprocess.run(['python3',str(Path(__file__).with_name('multicloud-resource-coverage.py')),'--first-39','--check'],cwd=ROOT,check=True)
 report={'review_date':'2026-10-28','baseline_commit':manifest['baseline_commit'],'scope':'Static diagram/source review of the original 39 architecture overviews; no cloud, provider, runtime or compliance validation.',
         'checks':['Overview matches authoring script','OCI skill layout checker','Transitive source declarations and pinned revisions','Cloud-specific icons and SVG embedding','Source-to-card labels and main-document pages','Existing-resource reference separation','PNG presence and hashes'],
         'blueprints':reviewed}
 if args.write_report:(ROOT/'docs/diagrams/review-first-39.json').write_text(json.dumps(report,indent=2)+'\n')
 print('39 overviews and complete resource/reference pages passed static review.')
if __name__=='__main__':main()
