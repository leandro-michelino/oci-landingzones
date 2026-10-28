#!/usr/bin/env python3
"""Two dedicated interconnect blueprints, including both cloud resource sides."""
import argparse
import importlib.util
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
def load(name):
 spec=importlib.util.spec_from_file_location(name,Path(__file__).with_name(name+'.py'))
 mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod);return mod
base=load('data-dr-batch-01');cloud=load('cloud-icons')
ITEMS=['networking/aws-oci-managed-interconnect','networking/gcp-oci-partner-interconnect']
def footer(d,text):
 d.box(text,20,1150,2460,135,kind='note')
 d.text('Local review 2026-10-28: schema validation and mocked plans only; no provisioning, BGP, packet flow or resilience test.\nSource CIDRs are examples; regions, provider offerings and BGP addresses require operator verification.',20,1340,2460,55,size=13)

def build(gcp=False):
 title='OCI + GCP | FastConnect and redundant Partner VLAN attachments' if gcp else 'OCI + AWS | Managed Interconnect with explicit create / accept activation'
 d=base.base.base.Diagram(toolkit=base.base.base.TOOLKIT,title=title)
 d.text(title,20,10,2460,45,size=25,bold=True)
 d.text('INTERCONNECT / Source review 2026-10-28 / Configuration topology, not operational evidence',20,65,2460,30,size=13)
 reg=d.group('region','OCI / supported region pair / explicit workload compartment',20,160,1090,900)
 vc=d.group('vcn','Private VCN\n10.56.0.0/16',30,80,990,660,parent=reg)
 sn=d.group('subnet','Workload subnet\n10.56.10.0/24',40,120,700,300,parent=vc)
 d.icon('Security Lists',120,160,parent=sn,size=55,label='Explicit attached security list',label_pos='top')
 d.text('Approved TCP ports only / remote subnet source\nallowed_tcp_ports=[] / no ingress by default\nPrivate IPs / no workload instances created',250,100,420,135,parent=sn,size=15)
 rt=d.icon('Route Table',800,480,parent=vc,size=52,label='Remote subnet → DRG',label_pos='top')
 drg=d.icon('DRG',990,480,parent=vc,size=55,label='DRG + VCN attachment',label_pos='bottom',border=True)
 d.connect(rt,drg,kind='plain',straight=True)
 d.text('No IGW, NAT, default Internet route, VPN or tenancy IAM policy.\nDRG system defaults provide route exchange; verify learned routes\nand export/import scope before adding other attachments.',40,550,900,80,parent=vc,size=15)
 remote=d.group('thirdparty','Google Cloud / existing project + supported region' if gcp else 'AWS / explicit account + supported local region',1320,160,1160,900)
 vpc=d.group('thirdparty','Custom regional VPC / no Internet default route' if gcp else 'Private VPC / 10.96.0.0/16 / explicit subnet AZ',30,80,1100,660,parent=remote)
 cloud.icon(d,'google_compute_network' if gcp else 'aws_vpc',95,95,parent=vpc,size=52,label='VPC',label_pos='right')
 subnet=d.group('thirdparty','Workload subnet / 10.96.10.0/24',45,180,1000,175,parent=vpc)
 d.text('No workload is created. '+('VMs must carry interconnect-client tag.\nScoped ingress + egress allow rules; tagged clients have explicit deny egress.' if gcp else 'Attach the supplied SG to approved workload ENIs.\nNo public IP assignment. Ingress + egress SG rules use approved ports and OCI subnet.'),25,75,950,80,parent=subnet,size=15)
 if gcp:
  router=cloud.icon(d,'google_compute_router',800,480,parent=vpc,size=55,label='Cloud Router / ASN 16550',label_pos='top')
  d.text('Custom advertisement: remote subnet only\nTwo router interfaces + peers / OCI ASN 31898\nBGP configuration gated by enable_bgp=false',400,545,650,80,parent=vpc,size=15)
  edge=cloud.icon(d,'google_compute_interconnect_attachment',150,480,parent=vpc,size=60,label='2 Partner VLAN attachments\nEdge domains 1 + 2 / MTU 1500',label_pos='top')
  d.connect(edge,router,kind='plain',straight=True)
  d.text('Google attachments emit pairing keys. OCI creates one private VC per key.\nApproved BGP address pairs are explicit inputs; partner provisioning and\nattachment activation must precede operational BGP verification.',35,780,1090,85,parent=remote,size=15)
 else:
  gw=cloud.icon(d,'aws_vpn_gateway',800,480,parent=vpc,size=55,label='VGW / used by Direct Connect\nNo VPN tunnel created',label_pos='top')
  edge=d.box('Direct Connect gateway\nDXGW ↔ VGW association',45,430,380,110,parent=vpc)
  d.connect(edge,gw,kind='plain',straight=True)
  d.text('Subnet route table + association / OCI subnet → VGW\nDXGW association advertises remote subnet only\nDXGW ASN 64512 / VGW ASN 64513',400,560,650,80,parent=vpc,size=15)
  d.text('OCI-first request targets aws_account_id and aws_region. Operator copies\nthe activation key and accepts it in AWS against the created DXGW.\nThe provider-managed Interconnect object is external to this Terraform root.',35,780,1090,85,parent=remote,size=15)
 d.connect(drg,edge,kind='fastconnect',label='2 private VCs / Partner Interconnect' if gcp else 'Managed Interconnect / create + accept',exit=(1,.5),entry=(0,.5),waypoints=[(1160,720),(1260,720),(1260,720)])
 footer(d,'DISABLED DEFAULTS: enable_foundation=false / enable_interconnect=false / costs_approved=false / region_pair_verified=false / application TCP port set empty.\n'+('Foundation creates two Google Partner attachments; activate_attachments=false. enable_bgp=false; enabling circuits requires two approved BGP address pairs.\nPartner bandwidth is selected through OCI; no guessed Google PARTNER bandwidth, VLAN or physical cross-connect is created. Private transport does not imply encryption.' if gcp else 'A single OCI managed-interconnect VC represents provider-managed redundant infrastructure. No customer VIF, BGP peer or physical cross-connect is invented.\nAWS acceptance/activation is an explicit operator step. Verify regional offering/account eligibility; generic hosted Direct Connect is a separate service.')+'\nAll source-declared resources and operator-supplied identifiers appear on companion detail pages. No live provisioning, packet flow or failover was tested.')
 return d

def main():
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--render',action='store_true');args=parser.parse_args()
 for gcp,slug in enumerate(ITEMS):
  d=build(bool(gcp));warnings=d.check();print(slug,warnings,flush=True)
  if warnings:raise RuntimeError('Fix layout warnings')
  path=ROOT/'blueprints'/slug/'architecture/architecture.drawio';d.save(str(path))
  if args.render and not d.render(str(path.with_suffix('.png')),scale=1.5):raise RuntimeError('PNG export failed')
  with path.open('a') as f:f.write('\n')
if __name__=='__main__':main()
