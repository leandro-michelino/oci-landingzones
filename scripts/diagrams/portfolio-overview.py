import os
import sys
from pathlib import Path
SKILL = Path(os.environ.get('OCI_DIAGRAM_SKILL', Path.home() / '.codex/skills/oci-architecture-diagrams'))
sys.path.insert(0, str(SKILL / 'scripts'))
from ocidraw import Diagram
OUT = Path(__file__).resolve().parents[2] / 'docs/assets'
d=Diagram(title='OCI Landing Zones — Portfolio Overview')
# Conceptual capability map: grouping denotes portfolio organization, not deployment dependencies.
def panel(label,x,y,w,h,parent=None,fill='#FFFFFF',stroke='#D6D0C8',size=18,color='#312D2A'):
    return d.group('other',label,x,y,w,h,parent=parent,style_extra=f'fillColor={fill};strokeColor={stroke};rounded=1;arcSize=12;fontSize={size};fontColor={color};fontStyle=1;spacingLeft=20;spacingTop=12;')
def card(title,desc,x,y,w,h,parent=None,fill='#FFFFFF',accent='#C74634'):
    p=panel('',x,y,w,h,parent,fill=fill,stroke='#E2DDD6')
    d.text(title,18,12,w-36,27,parent=p,size=20,bold=True,color=accent)
    d.text(desc,18,45,w-36,h-53,parent=p,size=15,color='#625D58')
    return p
# Header
panel('',0,0,1440,120,fill='#312D2A',stroke='#312D2A')
d.text('OCI Landing Zones',32,18,950,48,size=38,bold=True,color='#FFFFFF')
d.text('OCI-first foundations and solution blueprints',34,75,1000,26,size=21,color='#E8E1D9')
d.text('PORTFOLIO OVERVIEW',1110,39,294,28,size=16,bold=True,align='right',color='#EDC9BE')
oci=panel('ORACLE CLOUD INFRASTRUCTURE',0,142,1110,616,fill='#F8F6F2',stroke='#D6D0C8',size=19,color='#9B392A')
# Foundation: all four source family names
base=panel('FOUNDATION',20,58,1070,126,parent=oci,fill='#F0E9E0',stroke='#E3D8CA',size=15)
d.text('Core  /  CIS  /  Identity  /  Operating Entity',20,43,1030,31,parent=base,size=23,bold=True)
d.text('Tenancy baseline, access controls and delegated administration',20,83,1030,24,parent=base,size=17,color='#625D58')
# Six families, 2x3
for title,desc,col,row in [
 ('Networking','VCN, DRG and hybrid connectivity',0,0),
 ('Data Platform','Database and data service patterns',1,0),
 ('AI','GenAI, agents and model gateways',2,0),
 ('Extensions','Kubernetes and application services',0,1),
 ('VMware','Oracle Cloud VMware Solution',1,1),
 ('Industry','Sector-specific solution patterns',2,1),
]:
    card(title,desc,20+col*363,232+row*116,344,100,parent=oci)
d.text('SOLUTION FAMILIES',22,196,1040,26,parent=oci,size=15,bold=True,color='#625D58')
ops=panel('CROSS-CUTTING CAPABILITIES',20,478,1070,116,parent=oci,fill='#E9EFEA',stroke='#D0DDD2',size=15,color='#365648')
d.text('Operations  /  Compliance  /  Disaster Recovery  /  DevOps',20,43,1030,30,parent=ops,size=21,bold=True,color='#365648')
d.text('Cost controls, security posture, recovery patterns and delivery workflows',20,80,1030,23,parent=ops,size=16,color='#52685B')
# External clouds deliberately outside OCI; no transport or universal dependency implied.
cloud=panel('MULTICLOUD',1132,142,308,616,fill='#EEF2F5',stroke='#D3DCE2',size=19,color='#365466')
d.text('Selected blueprints',20,55,268,26,parent=cloud,size=18,color='#526571')
for title,desc,y in [('Azure','Connectivity, AI and DR',108),('AWS','Networking, Kubernetes and DR',222),('GCP','Networking, data, AI and DR',336)]:
    card(title,desc,16,y,276,94,parent=cloud,accent='#365466')
d.text('Integrations and prerequisites\nvary by blueprint.',20,486,268,58,parent=cloud,size=17,color='#526571')
# A useful reading guide, no generic review/process disclaimer.
d.text('Choose a blueprint   →   Review its architecture   →   Configure   →   Plan   →   Deploy & verify',5,781,1430,35,size=21,bold=True,align='center',color='#625D58')
warnings=d.check()
print('Layout warnings:',warnings)
if warnings: raise SystemExit(1)
d.save(str(OUT/'oci-landing-zones-banner.drawio'))
assert d.render(str(OUT/'oci-landing-zones-banner.png'),scale=1.5)
print('Created draw.io and PNG')

import shutil
import subprocess
cli = shutil.which('drawio') or '/Applications/draw.io.app/Contents/MacOS/draw.io'
subprocess.run([cli, '-x', '-f', 'svg', '-o', str(OUT / 'oci-landing-zones-banner.svg'), str(OUT / 'oci-landing-zones-banner.drawio'), '--no-sandbox', '--disable-gpu'], check=True)
