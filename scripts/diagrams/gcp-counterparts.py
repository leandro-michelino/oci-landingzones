#!/usr/bin/env python3
"""Five OCI/GCP counterparts with independently scoped roots and explicit external workflows."""
import argparse,importlib.util
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
def load(name):
 s=importlib.util.spec_from_file_location(name,Path(__file__).with_name(name+'.py'));m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
base=load('extensions-batch-03');cloud=load('cloud-icons')
ITEMS=[('networking/gcp-oci-hybrid-network-backbone','GCP and OCI hybrid backbone | Partner Interconnect plus independent HA VPN','network'),('disaster-recovery/gcp-oci-cross-cloud-dr','GCP and OCI DR | Private backup foundations and optional standby VM','dr'),('extensions/gke-oke-active-passive','OKE and GKE active/passive | Private clusters and external application recovery','gke'),('data-platform/oci-gcp-mysql-heatwave-dr','OCI MySQL and GCP Cloud SQL | Independent databases until replication setup','mysql'),('ai/gcp-oci-ai-gateway','OCI and GCP AI gateway | Private API routes and authenticated inference adapter','ai')]
def box(d,r,text,x,y,w=1200,h=140):return d.box(text,x,y,w,h,parent=r)
def build(kind,title):
 d=base.base.base.network.Diagram(toolkit=base.base.base.network.TOOLKIT,title=title)
 d.text(title,20,10,2940,45,size=25,bold=True)
 d.text('Official OCI Toolkit + native GCP stencils / Separate OCI and GCP execution roots / All creation and cost approval flags false',20,65,2940,30,size=13)
 d.text('Plain: ID/control-plane association. Solid/badged: optional configured route/circuit intent. Dashed: external workflow or prerequisite. No runtime evidence.',20,108,2940,30,size=13)
 r=d.group('region','OCI / explicit compartment and region / DEFAULT profile',20,160,1400,1120)
 g=d.group('thirdparty','Google Cloud / separately executed GCP root / existing project + ADC',1560,160,1400,1120)
 if kind=='network':
  vc=d.group('vcn','Private VCN and workload subnet / enable_oci=false / source CIDRs 10.95.0.0/16 and 10.95.10.0/24',80,80,1240,240,parent=r)
  drg=d.icon('DRG',700,510,parent=r,size=70,label='Optional DRG + VCN attachment\nScoped TCP rules / subnet route to peer through DRG',label_pos='top')
  d.connect(drg,vc,kind='plain',label='VCN attachment / configured peer subnet route',exit=(.5,0),entry=(.5,1),straight=True)
  net=box(d,g,'Private VPC/subnet / enabled=false / 10.96.10.0/24\nFlow logs + Private Google Access / no default Internet route\nOptional scoped VM ingress; optional paid NAT + explicit egress route',100,80)
  partner=cloud.icon(d,'google_compute_interconnect_attachment',700,510,parent=g,size=70,label='Two Partner VLAN attachments / primary + secondary\nPreactivation=false / separate pairing-key handoff\nCloud Router ASN 16550 / BGP disabled until assigned values verified',label_pos='top')
  d.connect(partner,net,kind='plain',label='VPC + Cloud Router association / BGP control plane',exit=(.5,0),entry=(.5,1),straight=True)
  d.connect(drg,partner,kind='fastconnect',label='Optional FastConnect + Partner Interconnect\nenable_interconnect / region-pair + cost approval / service pairing keys',straight=True,label_offset=(0,55))
  ipsec=box(d,r,'Optional VPN: two CPE + IPSec connections\nFour managed IKEv2 BGP tunnels after tunnel-ID discovery\nGCP HA gateway public IPs are explicit CPE inputs\nSeparate protected PSKs / no automatic discovery or failover',100,810,1200,155)
  vpn=cloud.icon(d,'google_compute_ha_vpn_gateway',700,885,parent=g,size=70,label='Optional HA VPN gateway / two public interfaces\nFour OCI endpoint mappings + IKEv2 tunnels\nIndependent VPN Cloud Router / ASN 64514 / BGP peers',label_pos='top')
  d.connect(ipsec,vpn,kind='vpn',label='Optional independently routed VPN / matching staged endpoint and key maps',straight=True,label_offset=(0,70))
  d.connect(ipsec,drg,kind='plain',label='IPSec drg_id',exit=(.5,0),entry=(.5,1),straight=True)
  d.connect(vpn,net,kind='plain',label='HA gateway network_id / private VPC',exit=(1,.5),entry=(1,.5),waypoints=[(2940,1045),(2940,310)],label_offset=(-130,0))
 elif kind=='dr':
  src=d.icon('OCI Object Storage',700,280,parent=r,size=80,label='Optional private versioned source backup bucket\nNamespace lookup only when OCI enabled + costs approved\nNo source objects, backup agent or transfer job',label_pos='top')
  dst=cloud.icon(d,'google_storage_bucket',700,280,parent=g,size=80,label='Optional Cloud Storage recovery bucket\nUniform IAM / public access prevented / versioning on\nforce_destroy=false / no transfer job or data objects',label_pos='top')
  d.connect(src,dst,kind='dashed',label='External export / authenticated TLS transfer / checksum / restore workflow',straight=True)
  vm=cloud.icon(d,'google_compute_instance',700,700,parent=g,size=80,label='Optional private standby VM / enable_workload=false\nExplicit compatible image / no public IP / Shielded VM / OS Login\nDedicated SA / deletion protection / no workload app installed',label_pos='top')
  d.connect(dst,vm,kind='dashed',label='External restore + explicit data-access grants / not configured',exit=(.5,1),entry=(.5,0),straight=True)
  box(d,r,'Private source VCN/subnet foundation\nNo IGW, NAT, service gateway or egress rules\nOptional peer-scoped ingress / no OCI application or database\nSource backup creation and recovery orchestration are external',100,670,1200,175)
  box(d,g,'Private VPC/subnet + flow logs + Cloud Router\nOptional tagged VM ingress / optional paid NAT + Internet route\nDedicated VM service account has no implicit storage-read grant',100,950,1200,120)
 elif kind=='gke':
  oke=d.icon('OCI Container Engine for Kubernetes',700,280,parent=r,size=80,label='Optional primary OKE cluster + separately gated node pool\nExisting prepared VCN / private endpoint + worker subnet IDs\nExplicit version, shape and image / no manifests',label_pos='top')
  gke=cloud.icon(d,'google_container_cluster',700,280,parent=g,size=80,label='Optional standby regional GKE Autopilot\nPrivate nodes + endpoint / dedicated node SA + node-role IAM\nWorkload Identity / deletion protection / no manifests',label_pos='top')
  d.connect(oke,gke,kind='dashed',label='External image / manifest / state replication, recovery and DNS cutover',straight=True)
  inputs=box(d,r,'Existing OKE network prerequisites\noci_vcn_id + oci_subnet_id / explicit node_subnet_ids\nAPI, node, pod, service and load-balancer security/egress\nRunner connectivity and OCI service access must be prepared',100,650,1200,170)
  d.connect(oke,inputs,kind='plain',label='Network and worker placement identifiers',exit=(.5,1),entry=(.5,0),straight=True)
  ranges=box(d,g,'Created VPC + private subnet / flow logs\nNamed pod range 10.97.0.0/16 + service range 10.98.0.0/20\nControl-plane example 172.28.0.0/28 / check overlap\nOptional NAT is separately billed / private API access needs routes',100,650,1200,170)
  d.connect(gke,ranges,kind='plain',label='network / subnetwork / secondary range bindings',exit=(.5,1),entry=(.5,0),straight=True)
  d.text('Cross-cloud network, DNS, application ingress, identity federation, data consistency and weighted routing are external. No automatic failover or RPO/RTO is installed.',100,1010,1200,80,parent=r,size=16)
 elif kind=='mysql':
  mysql=d.icon('MySQL Database System',700,280,parent=r,size=80,label='Optional OCI MySQL primary / enable_database=false\nPrivate VCN/subnet + scoped TCP 3306 NSG\nReviewed shape / AD / protected admin credentials',label_pos='top')
  sql=cloud.icon(d,'google_sql_database_instance',700,280,parent=g,size=80,label='Optional independent Cloud SQL MySQL 8.0 instance\nPrivate IP only / regional HA / encrypted-only connections\nBackups + binlogs / protected admin user / deletion protection',label_pos='top')
  d.connect(mysql,sql,kind='dashed',label='External-source registration / TLS + GTID/binlog compatibility / replication job NOT configured',straight=True)
  heat=d.icon('MySQL HeatWave',700,700,parent=r,size=75,label='Optional HeatWave cluster / enable_heatwave=false\nRequires created MySQL DB System\nAnalytics capacity does not replicate to Cloud SQL',label_pos='top')
  d.connect(heat,mysql,kind='plain',label='db_system_id / analytics cluster binding',exit=(.5,0),entry=(.5,1),straight=True)
  psa=box(d,g,'Private VPC + subnet / separate allocated peering range\nService Networking connection / private_network binding\nCustom-route export and service-range return advertisements\nNeed explicit transport, DNS, security and TLS acceptance',100,650,1200,170)
  d.connect(sql,psa,kind='plain',label='private_network / allocated_ip_range / service connection dependency',exit=(.5,1),entry=(.5,0),straight=True)
  d.text('No replication channel, DMS job, import, source data, automatic promotion, DNS cutover or HeatWave capacity exists on the GCP side. Protect both passwords and backups.',100,1010,1200,80,parent=r,size=16)
 else:
  api=d.icon('API Gateway',700,280,parent=r,size=80,label='Optional PRIVATE OCI API Gateway / existing subnet\nOptional /ai/oci/inference + /ai/gcp/inference HTTPS backends\nDeployment gated by adapter_auth_verified + reviewed URLs',label_pos='top')
  run=cloud.icon(d,'google_cloud_run_v2_service',700,280,parent=g,size=80,label='Optional internal-only Cloud Run adapter / explicit image\nDedicated SA / Vertex AI IAM role / explicit run.invoker identities\nDirect VPC ALL_TRAFFIC egress / deletion protection',label_pos='top')
  d.connect(api,run,kind='dashed',label='External secure adapter URL handoff / private route + Google caller token required',straight=True)
  ocib=box(d,r,'Existing OCI inference adapter / HTTPS URL\nHandles caller validation + OCI request signing\nNot created; raw OCI inference endpoint is not a generic HTTP adapter\nNo API Gateway token broker or shared credential injection',100,650,1200,170)
  d.connect(api,ocib,label='Configured /oci/inference HTTP backend when deployment enabled',exit=(.5,1),entry=(.5,0),straight=True)
  vertex=box(d,g,'Existing Vertex AI model/API + separately prepared service APIs\nAdapter image must implement Google ADC inference calls\nNo custom model, dedicated endpoint, image build or token broker\nPrivate VPC and optional NAT do not prove API reachability',100,650,1200,170)
  d.connect(run,vertex,kind='dashed',label='Application implementation + API/DNS/egress prerequisites',exit=(.5,1),entry=(.5,0),straight=True)
  d.text('No public allUsers or allAuthenticatedUsers invoker. OCI adapters enforce caller authentication; operator attestations are not runtime proof. No inference or token exchange tested.',100,1010,1200,80,parent=r,size=16)
 return base.finish(d,'DEFAULT RESULT: No cloud resources; cost and creation/workload flags false. Local metadata guards remain. Separate roots and credentials for each cloud.\nNative detail pages enumerate every root/module/companion declaration, including private networking, flow logs, IAM and service-specific dependencies.\nExisting projects/APIs, scoped credentials, region eligibility, quota, supported images/versions, address plans, routes and DNS are explicit prerequisites.',True)
def main():
 p=argparse.ArgumentParser();p.add_argument('--render',action='store_true');p.add_argument('--blueprint',action='append');a=p.parse_args()
 for slug,title,kind in ITEMS:
  if a.blueprint and slug not in a.blueprint:continue
  d=build(kind,title);w=d.check()+d._crossings([n for n in d.nodes if n.kind=='text']);print(slug,w,flush=True);assert not w
  path=ROOT/'blueprints'/slug/'architecture/architecture.drawio';d.save(str(path))
  if a.render:assert d.render(str(path.with_suffix('.png')),scale=1.5)
  with path.open('a') as f:f.write('\n')
if __name__=='__main__':main()
