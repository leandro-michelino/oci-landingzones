#!/usr/bin/env python3
"""Source-bounded catalog continuation 36-40: desktops and Kubernetes extensions."""
import argparse
import importlib.util
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
def load(name):
 spec=importlib.util.spec_from_file_location(name,Path(__file__).with_name(name+'.py'))
 mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod);return mod
base=load('ai-industry-batch-03');cloud=load('cloud-icons')
ITEMS=[
 ('industry/secure-desktops','Secure Desktops | Optional pool and existing network inputs','desktops'),
 ('extensions/oke','OKE extension | Optional cluster and node pool on supplied networks','oke'),
 ('extensions/aks-oke-active-passive','OCI + Azure Kubernetes | Separate foundations and optional DNS failover','aks'),
 ('extensions/eks-oke-active-passive','OCI + AWS Kubernetes | Separate foundations and optional DNS failover','eks'),
 ('extensions/oke-service-mesh','OKE Service Mesh | Optional add-on definition and independent APM domain','mesh'),
]
def header(title,index,wide=False):
 d=base.network.Diagram(toolkit=base.network.TOOLKIT,title=title)
 w=2940 if wide else 2460
 d.text(title,20,10,w,45,size=25,bold=True)
 d.text(f'INDUSTRY / EXTENSIONS {index:02} / Official OCI Toolkit v24.2 + provider-native glyphs / Source configuration only',20,65,w,30,size=13)
 d.text('Plain: ID/configuration associations. Solid arrows: configured route/action intent. Dashed: external workflows or prerequisites. No line proves working traffic.',20,108,w,30,size=13)
 return d

def desktops(title,index):
 d=header(title,index)
 r=d.group('region','OCI / selected region and compartment; tenancy fallback',20,160,2460,900)
 net=d.group('other','Existing VCN / desktop subnet / NSGs / no network resources created',40,80,1530,600,parent=r)
 pool=d.box('Secure Desktops pool / create_desktop_pool=false\nExisting subnet_id + vcn_id + nsg_ids\nMaximum 2 / standby 0 / VM.Standard.E4.Flex\nBoot 100 GB / storage enabled 50 GB / preserved volumes',520,160,920,160,parent=net)
 image=d.box('Existing approved desktop image\nImage ID / name / OS inputs null\nWindows 10/11 BYOL acknowledgement false',40,170,370,140,parent=net,kind='optional')
 d.connect(pool,image,kind='plain',label='image configuration',straight=True)
 private=d.box('Optional private_access_details block\nAdded only with private_access_subnet_id\nExisting VCN/subnet/NSGs; IP/FQDN inputs\nNot a separate created endpoint resource',520,390,920,140,parent=net,kind='optional')
 d.connect(private,pool,kind='plain',label='Pool private-access configuration',exit=(.5,0),entry=(.5,1),straight=True)
 backup=d.box('Existing storage backup policy ID / null\nNo backup policy is created',1680,170,700,115,parent=r,kind='optional')
 d.connect(pool,backup,kind='plain',label='storage_backup_policy_id / optional',exit=(1,.5),entry=(0,.5),waypoints=[(1640,480),(1640,387.5)])
 alarms=d.icon('Alarms',1850,570,parent=r,size=60,label='Alarms / alarms={}',label_pos='top')
 dest=d.box('Existing per-alarm destination IDs\nNo notification topic or subscription created',1680,720,700,100,parent=r,kind='optional')
 d.connect(alarms,dest,kind='plain',label='destinations / explicit IDs',exit=(.5,1),entry=(.24285714,0),straight=True)
 d.icon('Policies',260,790,parent=r,size=50,label='Optional IAM policy / statements=[]\nHome provider / policy compartment fallback tenancy',label_pos='top')
 d.text('Pool configuration: display/keyboard/pointer on; audio, clipboard, drives, printing and video off.\nStart/stop schedules null; session lifecycle actions false with disconnect/inactivity inputs null.\nUser onboarding, identity groups, access transport and application targets remain external.',600,735,1000,110,parent=r,size=15)
 return base.finish(d,'DEFAULT RESULT: No cloud resources; pool disabled, alarms empty and policy statements empty. Image, network, AD and backup-policy selections are operator inputs.\nPrivate-access details are pool configuration, not a created VCN, subnet, NSG, VPN or standalone endpoint. No user-to-desktop or application data path is invented.\nAn existing desktop_pool_id is only an output/reference fallback; this code does not attach new policies or configuration to an existing pool.\nNo desktop session, client reachability, BYOL entitlement, backup/restore, alarm delivery or cloud deployment was tested. Historical provider validation is unchanged.')

def oke(title,index):
 d=header(title,index)
 r=d.group('region','OCI / selected region and compartment; existing network inputs',20,160,2460,900)
 vc=d.group('other','Existing VCN / vcn_id=null / no CIDR assumed',40,80,2380,650,parent=r)
 api=d.group('other','Existing endpoint subnet / optional endpoint_subnet_id',40,90,1000,250,parent=vc)
 cluster=d.icon('OCI Container Engine for Kubernetes',500,155,parent=api,size=75,label='OKE cluster / enable_cluster=false\nendpoint_public_ip_enabled=false when endpoint block exists',label_pos='top')
 nodes=d.group('other','Existing worker subnets / node_subnet_ids=[]',1270,90,1060,250,parent=vc)
 pool=d.box('Node pool / enable_node_pool=false\nCreated cluster fallback or supplied cluster_id\n1 node per subnet / shape, version and image inputs null',60,100,940,100,parent=nodes)
 d.connect(pool,cluster,kind='plain',label='cluster_id',straight=True)
 lbs=d.box('Existing service-LB subnet IDs / []\nOnly cluster options.service_lb_subnet_ids\nNo Load Balancer or Kubernetes Service created',40,435,1000,125,parent=vc,kind='optional')
 d.connect(lbs,cluster,kind='plain',label='Optional service-LB subnet configuration',exit=(.5,0),entry=(.5,1),straight=True)
 d.text('Cluster CNI input: OCI_VCN_IP_NATIVE. Kubernetes version is operator supplied.\nEndpoint NSGs=[]; no security rules, route tables, gateways or IAM are created.\nAn endpoint subnet is optional in code; the false public-IP flag alone does not\ncreate an API subnet, private endpoint or a working operator access path.',1270,420,1060,160,parent=vc,size=17)
 d.text('Worker subnet, image and shape choices are explicit inputs; no autoscaling, workload, ingress controller or image registry is deployed.',50,790,2320,65,parent=r,size=16)
 return base.finish(d,'DEFAULT RESULT: No resources. enable_cluster=false and enable_node_pool=false. Exactly two resource declarations, with existing-resource identifier references.\nEndpoint configuration is emitted only when endpoint_subnet_id is non-null. CIDRs and actual existing network exposure are not inferred.\nNode pool uses the selected cluster and supplied worker subnets. Network reachability, compatible image/version, IAM and application manifests require separate review.\nNo cluster, nodes, pods, service Load Balancer, private access, autoscaling or runtime Kubernetes connection was provisioned or tested.')

def mesh(title,index):
 d=header(title,index)
 r=d.group('region','OCI / optional cluster add-on and independent tracing container',20,160,2460,900)
 cluster=d.icon('OCI Container Engine for Kubernetes',380,280,parent=r,size=75,label='Existing OKE cluster\ncluster_id=null / not created',label_pos='top')
 addon=d.box('OKE add-on definition / enable_service_mesh_addon=false\naddon_name=ServiceMesh / addon_version=null\noverride_existing=false / remove resources on delete=false\naddon_configurations=[] / operator supplied key/value entries',850,180,1450,200,parent=r)
 d.connect(addon,cluster,kind='plain',label='cluster_id',straight=True)
 apm=d.icon('Application Performance Monitoring',380,680,parent=r,size=70,label='Optional APM domain / enable_apm_domain=false\nis_free_tier=true',label_pos='top')
 d.text('Independent resource: no add-on-to-APM binding, agent injection, exporter,\ningestion key or tracing endpoint configuration is declared. The operator must\nconfigure tracing separately; no automatic telemetry connector is drawn.',850,585,1450,160,parent=r,size=19)
 return base.finish(d,'DEFAULT RESULT: No resources; both flags false. Exactly two declarations: oci_containerengine_addon.service_mesh and oci_apm_apm_domain.tracing.\nThe ServiceMesh add-on name is a source default, not a verified supported add-on/version for a particular cluster or region. No mesh-policy resources are created.\nNo cluster, network, proxies, application manifests, virtual services/deployments, mTLS policy, traffic routing or tracing exporter is declared here.\nThe add-on ID association is configuration only. No installation, service-to-service traffic, mTLS, tracing or cloud deployment was tested.')

def primary(d):
 r=d.group('region','OCI primary / selected region and compartment; tenancy fallback',20,160,1420,1120)
 vc=d.group('vcn','OKE VCN / enable_oke_networking=true\n10.42.0.0/16',50,80,1320,600,parent=r)
 api=d.group('subnet','API subnet / 10.42.10.0/24\nPublic IPs prohibited by default',35,90,500,180,parent=vc)
 cluster=d.icon('OCI Container Engine for Kubernetes',250,125,parent=api,size=55,label='Optional OKE / cluster=false\nPrivate API flag / CNI input null',label_pos='top')
 workers=d.group('subnet','Worker subnet / 10.42.20.0/24\nPublic IPs prohibited',700,90,570,180,parent=vc)
 pool=d.box('Optional node pool / flag=false\nE5 Flex / 1 per subnet / image + version null',40,85,490,70,parent=workers)
 d.connect(pool,cluster,kind='plain',label='Selected cluster_id / optional',straight=True)
 lb=d.group('subnet','Service-LB subnet / 10.42.30.0/24\nPublic IPs permitted / no LB created',35,330,500,145,parent=vc)
 d.connect(lb,cluster,kind='plain',label='Service-LB subnet option',exit=(.5,0),entry=(.5,1),waypoints=[(355,540),(355,540)])
 rt=d.icon('Route Table',1100,430,parent=vc,size=45,label='Shared RT / default → IGW',label_pos='top')
 igw=d.icon('Internet Gateway',1320,430,parent=vc,size=50,label='IGW',label_pos='top',border=True)
 d.connect(api,rt,kind='plain',label='route_table_id',exit=(1,.5),entry=(0,.5),waypoints=[(690,420),(690,535),(1100,535),(1100,670)])
 d.connect(workers,rt,kind='plain',exit=(1,.5),entry=(.5,0),waypoints=[(1365,420),(1365,550),(1170,550)])
 d.connect(lb,rt,kind='plain',exit=(1,.5),entry=(0,.5),waypoints=[(690,642.5),(690,670)])
 d.connect(rt,igw,label='0.0.0.0/0',straight=True)
 d.text('SLs: API TCP 6443 from 0.0.0.0/0; node CIDRs 6443/12250 + ICMP 3/4.\nNodes: all VCN ingress; LB-source 80/443 from 0.0.0.0/0; SSH input null; all egress.\nAn IGW route does not provide Internet egress to private worker addresses. No NAT or SGW.',35,505,1240,80,parent=vc,size=14)
 d.box('Four local metadata/validation contracts\nNetwork + Interconnect always; GitOps + steering contracts enabled by default\nArgo CD / Flux are NOT installed; repository URL=null\nNo manifests, replication or application ingress deployed',50,780,1320,155,parent=r,kind='note')
 d.text('Cluster/node creation is independently optional. Existing VCN/subnet/cluster IDs can be selected.\nNo DRG, FastConnect, peering, VPN or remote-prefix route is declared by this entry point.\nDefault contracts have null endpoint/circuit/secondary IDs; source defaults are not a complete failover configuration.',50,970,1320,110,parent=r,size=15)
 return vc

def azure(d):
 r=d.group('thirdparty','Azure standby / separately deployed Bicep / resource-group location',1540,160,1420,1120)
 vc=d.group('thirdparty','VNet / 10.62.0.0/16',50,80,1320,600,parent=r)
 sn=d.group('thirdparty','AKS subnet / 10.62.10.0/24',40,90,860,330,parent=vc)
 cluster=cloud.icon(d,'Microsoft.ContainerService/managedClusters',430,145,parent=sn,size=75,label='AKS / SystemAssigned identity\nBase / Free / Kubernetes 1.36 input',label_pos='top')
 d.text('Managed system pool: 1 × Standard_D4ds_v5 / Linux / VMSS\nAzure CNI / standard LB / outboundType=loadBalancer\nAPI private/authorized-IP settings are not declared',30,230,800,80,parent=sn,size=15)
 rt=cloud.icon(d,'Microsoft.Network/routeTables',1100,200,parent=vc,size=50,label='UDR / BGP propagation enabled',label_pos='top')
 nsg=cloud.icon(d,'Microsoft.Network/networkSecurityGroups',1100,450,parent=vc,size=50,label='NSG / inbound 80 + 443 from *\nVNet node-to-node / default rules apply',label_pos='top')
 internet=d.box('Internet next hop\nConfigured UDR default',40,470,850,80,parent=vc)
 d.connect(sn,rt,kind='plain',label='routeTable.id',exit=(1,.2),entry=(0,.5),waypoints=[(2520,396),(2520,440)])
 d.connect(sn,nsg,kind='plain',label='networkSecurityGroup.id',exit=(1,.8),entry=(.5,0),waypoints=[(2580,594),(2690,594)])
 d.connect(rt,internet,label='0.0.0.0/0 → Internet',exit=(1,.5),entry=(1,.5),waypoints=[(2880,440),(2880,750)])
 d.box('Five Bicep resource declarations\nVNet / subnet / route table / NSG / AKS\nSystem-pool and load-balancer settings are managed-cluster profiles.\nNo ExpressRoute circuit, gateway, VNet peering or OCI return route created.',50,780,1320,155,parent=r,kind='note')
 d.text('AKS outputs are manually supplied to OCI contracts. No deployed application endpoint is inferred\nfrom the AKS control-plane FQDN. Kubernetes versions are source parameters, not verified availability.',50,970,1320,100,parent=r,size=15)
 return vc

def aws(d):
 r=d.group('thirdparty','AWS standby / separately deployed CloudFormation / selected region',1540,160,1420,1120)
 vc=d.group('thirdparty','VPC / 10.64.0.0/16',50,80,1320,600,parent=r)
 cloud.icon(d,'AWS::EC2::VPC',70,45,parent=vc,size=35)
 placement=d.group('thirdparty','Both AZs / EKS + node-group placement',30,65,1180,175,parent=vc)
 subs=[]
 for i,cidr in enumerate(['10.64.10.0/24','10.64.20.0/24']):
  sn=d.group('thirdparty',f'Subnet {i+1} / AZ {i+1} / {cidr}\nMapPublicIpOnLaunch=false',10+i*600,40,560,115,parent=placement);subs.append(sn)
  d.text('Cluster + node-group subnet selection',15,70,530,30,parent=sn,size=13)
 cluster=cloud.icon(d,'AWS::EKS::Cluster',250,330,parent=vc,size=65,label='EKS / private API only\nKubernetes 1.36 input',label_pos='top')
 pool=d.box('Managed node group / ON_DEMAND\nAL2023 x86_64 / 2 × t3.medium\nDesired 2 / min 1 / max 4',470,280,470,115,parent=vc)
 d.connect(pool,cluster,kind='plain',label='ClusterName',straight=True)
 d.connect(placement,cluster,kind='plain',label='SubnetIds / both AZs',exit=(0,.8285714),entry=(0,.5),waypoints=[(1610,450),(1610,570)])
 d.connect(placement,pool,kind='plain',label='Subnets / both AZs',exit=(.57203390,1),entry=(.5,0),straight=True)
 rt=cloud.icon(d,'AWS::EC2::RouteTable',1100,330,parent=vc,size=45,label='Shared RT / 2 subnet associations',label_pos='bottom')
 igw=cloud.icon(d,'AWS::EC2::InternetGateway',1230,330,parent=vc,size=50,label='IGW + attachment',label_pos='bottom')
 for i,sn in enumerate(subs):
  d.connect(sn,rt,kind='plain',exit=(1,.95),entry=(.5,0),waypoints=[(2210 if i==0 else 2850,454.25),(2210 if i==0 else 2850,500),(2690,500)])
 d.connect(rt,igw,label='Default route',straight=True)
 sg=cloud.icon(d,'AWS::EC2::SecurityGroup',1100,500,parent=vc,size=45,label='Cluster SG / TCP 443 from 10.0.0.0/8\n443 egress to VPC only',label_pos='top')
 d.connect(sg,cluster,kind='plain',label='SecurityGroupIds',exit=(0,.5),entry=(.5,1),waypoints=[(2550,740),(2550,700),(1840,700)])
 d.text('Private workers: no public IP/NAT/VPC endpoints configured. An IGW route alone is insufficient for Internet egress.\n5 control-plane log types enabled; VPC flow-log destination is a separate explicitly declared Log Group.',35,535,1250,60,parent=vc,size=14)
 key=cloud.icon(d,'AWS::KMS::Key',170,850,parent=r,size=50,label='KMS key / rotation on',label_pos='top')
 logs=cloud.icon(d,'AWS::Logs::LogGroup',650,850,parent=r,size=50,label='VPC flow-log group / 30 days',label_pos='top')
 flow=cloud.icon(d,'AWS::EC2::FlowLog',1180,850,parent=r,size=50,label='VPC Flow Log / ALL',label_pos='top')
 d.connect(key,logs,kind='plain',label='KmsKeyId',straight=True)
 d.connect(flow,logs,label='Log delivery / dedicated role',straight=True)
 d.connect(vc,flow,kind='plain',label='ResourceId / VPC',exit=(1,.9),entry=(1,.5),waypoints=[(2935,780),(2935,1010)])
 d.connect(key,cluster,kind='plain',label='Secret EncryptionConfig',exit=(0,.5),entry=(0,.5),waypoints=[(1570,1010),(1570,570)])
 d.text('IAM: cluster role → EKS; node role → node group; flow-log role → delivery (all three declared).\nNo Direct Connect, virtual gateway, private endpoints, NAT or OCI return route is created.\nNode-role and cluster-role grants do not prove registration, image pulls or application readiness.',50,970,1320,100,parent=r,size=15)
 return vc

def dns(d,secondary):
 r=d.group('region','OCI DNS / home provider + optional regional health monitor / outside the workload VCNs',20,1360,2940,430)
 policy=d.icon('DNS',870,130,parent=r,size=60,label='Optional FAILOVER policy / Traffic Management=false\nCNAME / TTL 30 / primary 0, standby 1 / limit 1',label_pos='top')
 attachment=d.box('Optional steering-policy attachment\nExisting zone ID / app.example.com default',570,285,600,90,parent=r)
 zone=d.box('Existing DNS zone / ID null\nNo DNS zone is created',35,285,430,90,parent=r,kind='optional')
 monitor=d.icon('Health Checks',1510,130,parent=r,size=60,label='Optional HTTP monitor / TM + health flags\nHTTPS 443 / / / 30 s interval / 10 s timeout',label_pos='top')
 targets=d.box('Existing application targets / both endpoint inputs null\nOCI primary + '+secondary+' standby; applications/ingress remain external\nThese are application answers, not Kubernetes API endpoints',1920,150,960,125,parent=r,kind='optional')
 d.connect(attachment,policy,kind='plain',label='steering_policy_id',exit=(.5,0),entry=(.5,1),straight=True)
 d.connect(attachment,zone,kind='plain',label='zone_id / domain_name',straight=True)
 d.connect(policy,monitor,kind='plain',label='Optional health_check_monitor_id / existing override allowed',straight=True)
 d.connect(policy,targets,kind='plain',label='answers.rdata / primary + standby',exit=(.5,1),entry=(0,1),waypoints=[(890,1610),(1840,1610),(1840,1635)])
 d.connect(monitor,targets,label='Optional configured probe targets',exit=(1,.5),entry=(0,0),waypoints=[(1850,1490),(1850,1510),(1940,1510)])
 d.text('DNS policy returns an answer; it does not forward application packets or replicate data. Health checks require reachable targets. No active-active weights are implemented.\nThe default GitOps/steering contracts store metadata only. Optional real DNS resources do not install applications, data synchronization or failover runbooks.',40,380,2840,45,parent=r,size=14)

def multicloud(title,index,azure_side):
 d=header(title,index,True);vc=primary(d);other=azure(d) if azure_side else aws(d)
 d.connect(vc,other,kind='dashed',label='EXTERNAL partner Interconnect / supplied circuit IDs only; edge gateways, peering and routes not created',exit=(1,.95),entry=(0,.95),straight=True,label_offset=(0,65))
 dns(d,'Azure' if azure_side else 'AWS')
 d.box('SOURCE DEFAULTS ARE INCOMPLETE: OCI network enabled, OKE/node flags false, real Traffic Management false; circuit/secondary/application IDs null.\nIPSec backup is explicitly forbidden by this pattern. Companion Azure/AWS templates deploy separately and do not establish the intercloud path.\nNo workloads, GitOps controller, cluster autoscaling, application LB, data replication or working recovery path is delivered by the OCI contracts.\nAll conditional OCI/cloud declarations and metadata contracts are enumerated in native companion pages; no provisioning or failover was tested.',20,1840,2940,140,kind='note')
 d.text('Source / rendered-diagram review: 2026-10-28. Historical Terraform/provider and earlier live-test evidence remain unchanged. No cloud operations were run in this diagram batch.',20,2020,2940,45,size=13)
 return d

def aks(title,index):return multicloud(title,index,True)
def eks(title,index):return multicloud(title,index,False)

def main():
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--render',action='store_true');parser.add_argument('--blueprint',action='append',choices=[i[0] for i in ITEMS]);args=parser.parse_args()
 for index,(slug,title,kind) in enumerate(ITEMS,36):
  if args.blueprint and slug not in args.blueprint:continue
  d=globals()[kind](title,index);warnings=d.check()+d._crossings([n for n in d.nodes if n.kind=='text']);print(slug,warnings,flush=True)
  if warnings:raise RuntimeError('Fix layout warnings before export')
  path=ROOT/'blueprints'/slug/'architecture/architecture.drawio';d.save(str(path))
  if args.render and not d.render(str(path.with_suffix('.png')),scale=1.5):raise RuntimeError('PNG export failed')
  with path.open('a') as stream:stream.write('\n')
if __name__=='__main__':main()
