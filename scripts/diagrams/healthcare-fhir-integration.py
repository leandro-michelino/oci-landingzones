#!/usr/bin/env python3
"""FHIR API/queue foundation with existing hospital, identity and worker boundaries."""
import importlib.util
from pathlib import Path
spec=importlib.util.spec_from_file_location('base',Path(__file__).with_name('networking-batch-01.py'))
base=importlib.util.module_from_spec(spec);spec.loader.exec_module(base)
SLUG='industry/healthcare-fhir-integration'
def build():
 d=base.Diagram(toolkit=base.TOOLKIT,title='Hospital integration and FHIR | Private API mediation and optional event queue')
 d.text('Hospital integration and FHIR | Private API mediation and optional event queue',20,10,2740,45,size=25,bold=True)
 d.text('Source-defined OCI infrastructure / External FHIR server, identity and clinical adapters / All cloud creation disabled by default',20,70,2740,30,size=14)
 d.text('Solid: declared routes, API backend/token validation or logging. Plain: bindings. Dashed: external transport / middleware / workflow. No line proves runtime behavior.',20,112,2740,30,size=13)
 existing=d.group('thirdparty','Existing hospital / approved backend environment / location verified by operator',20,180,600,1050)
 client=d.box('EHR / HIS / LIS / PACS clients\nApproved hospital prefixes / TLS + Bearer token\nSystems and private transport are not created',20,80,560,120,parent=existing,kind='thirdparty_component')
 adapter=d.box('HL7 v2 / other source adapters\nEXTERNAL / mapping, ACK/NACK, retries, reconciliation\nNo MLLP listener or conversion engine created',20,290,560,130,parent=existing,kind='optional')
 server=d.box('Existing FHIR R4 server / HTTPS\nEXTERNAL / fhir_backend_url + approved prefixes\nPatient/resource authorization, consent, profiles and persistence\nNot an API Gateway feature; server software not deployed',20,500,560,150,parent=existing,kind='thirdparty_component')
 identity=d.box('Existing identity / JWKS endpoint\nHTTPS JWKS readable without authentication\nExact issuer + audience inputs / no identity system created',20,770,560,130,parent=existing,kind='thirdparty_component')
 reg=d.group('region','OCI / approved region + explicit integration compartment',760,180,2000,1050)
 vc=d.group('vcn','Private integration VCN\n10.121.0.0/16 / example',40,80,1900,610,parent=reg)
 api=d.group('subnet','Private API subnet\n10.121.10.0/24',70,100,900,320,parent=vc)
 sn=d.group('subnet','Private integration subnet\n10.121.20.0/24',1100,100,730,320,parent=vc)
 gw=d.icon('API Gateway',170,150,parent=api,size=65,label='PRIVATE gateway / optional',label_pos='top')
 dep=d.box('API deployment / optional / path_prefix=/fhir\nMetadata + five resource collection/instance routes\nGET only by default / no DELETE\nTOKEN_AUTHENTICATION / issuer + audience / TLS verified',360,85,500,140,parent=api)
 d.connect(gw,dep,kind='plain',label='gateway_id',straight=True)
 trust=d.box('Optional existing certificate / CA bundles\ncertificate_id + ca_bundle_ids / no CA created',200,40,480,45,parent=vc,kind='optional')
 d.connect(trust,gw,kind='plain',exit=(0,.5),entry=(0,.3),waypoints=[(850,322.5),(850,497)])
 d.text('NSG ingress: approved clients / 443\nNSG egress: FHIR backend + JWKS prefixes / 443\nNo response cache, payload logger or FHIR validator declared',30,240,840,65,parent=api,size=14)
 worker=d.box('External integration worker / not created\nHandoff: integration subnet + NSG IDs\nNo Compute, Function, producer or consumer deployed',60,95,610,130,parent=sn,kind='optional')
 d.text('NSG: regional OSN HTTPS egress only\nNo inbound listener or automatic clinical message pipeline',30,250,670,50,parent=sn,size=14)
 rt=d.icon('Route Table',300,500,parent=vc,size=50,label='Shared private RT',label_pos='top')
 drg=d.icon('DRG',0,500,parent=vc,size=55,label='Existing DRG\nVCN attachment if supplied',label_pos='bottom',border=True)
 sgw=d.icon('Service Gateway',1900,500,parent=vc,size=55,label='SGW / supported regional OSN',label_pos='top',border=True)
 for i,subnet in enumerate([api,sn]):
  d.connect(subnet,rt,kind='plain',exit=(.5,1),entry=(.5,0),waypoints=[(subnet.center()[0],705+10*i),(1100,705+10*i)])
 d.connect(rt,drg,label='Client / backend / JWKS prefixes',straight=True)
 d.connect(rt,sgw,label='Regional OSN route',straight=True)
 d.connect(client,drg,kind='dashed',label='External private transport + return routes',exit=(1,.5),entry=(0,.5),waypoints=[(650,320),(650,760)])
 d.connect(drg,gw,kind='dashed',label='External routed API access / 443',exit=(.5,0),entry=(0,.5),waypoints=[(800,510)])
 d.connect(dep,server,label='HTTP_BACKEND URL / verified TLS',exit=(1,.3),entry=(1,.5),waypoints=[(1760,487),(1760,695),(700,695),(700,755)])
 d.connect(dep,identity,label='REMOTE_JWKS / verified TLS',exit=(1,.7),entry=(1,.5),waypoints=[(1780,543),(1780,685),(720,685),(720,1015)])
 d.connect(adapter,worker,kind='dashed',label='External mapping / worker deployment',exit=(1,.5),entry=(.5,0),waypoints=[(680,535),(680,220),(2265,220)])
 osn=d.group('osn','Regional OSN / Queue API supported by SGW',1050,760,900,220,parent=reg)
 queue=d.icon('OCI Queue',680,110,parent=osn,size=65,label='Optional Queue\n24-hour retention / DLQ after 5 deliveries',label_pos='bottom')
 key=d.box('Existing KMS key / no key or Vault created\nkms_key_id + kms_policies_ready required\nIAM/KMS permissions remain external',35,65,430,120,parent=osn,kind='optional')
 d.connect(key,queue,kind='plain',label='custom_encryption_key_id',straight=True)
 d.connect(sgw,osn,label='Regional service path',exit=(.5,1),entry=(1,.5),waypoints=[(2700,1050)])
 d.connect(worker,queue,kind='dashed',label='External producer / consumer + IAM',exit=(1,.5),entry=(1,.5),waypoints=[(2650,520),(2650,1050)])
 logs=d.icon('Logging',520,865,parent=reg,size=60,label='2 subnet flow logs + log group\n30 days / not clinical access audit',label_pos='top')
 for i,subnet in enumerate([api,sn]):
  x=[1785,2660][i];y=900+10*i
  d.connect(subnet,logs,label='Subnet OCISERVICE flowlogs' if i==0 else '',exit=(1,.9),entry=(.5,0),waypoints=[(x,subnet.abs[1]+.9*subnet.h),(x,y),(1280,y)])
 d.text('No IGW, NAT, public endpoint or Internet default route.\nHospital transport, private DNS, clinical authorization and adapters need separate implementation and testing.',50,990,1880,45,parent=reg,size=13)
 d.box('DEFAULTS: enable_foundation/api/queue=false; costs_approved=false. Local guard + FHIR metadata contracts only.\nAPI requires approved client/backend/JWKS prefixes, HTTPS URLs, issuer/audience values, existing DRG and acknowledged backend authorization. Queue is independently enabled with an existing KMS key.\nFHIR server software, persistence, SMART scopes, consent, HL7 mappings, event workers, replay and clinical audit are not created. The patient-data blueprint remains an independent project.\nSource/schema review 2026-10-28: oracle/oci 9.11.0; 11 mocked plans passed. No apply, token exchange, FHIR transaction, mapping or end-to-end interoperability test.',20,1330,2740,155,kind='note')
 return d
if __name__=='__main__':
 d=build();warnings=d.check()+d._crossings([n for n in d.nodes if n.kind=='text']);assert not warnings,warnings
 path=base.ROOT/'blueprints'/SLUG/'architecture/architecture.drawio'
 d.save(str(path));assert d.render(str(path.with_suffix('.png')),scale=1.5)
 with path.open('a') as f:f.write('\n')
