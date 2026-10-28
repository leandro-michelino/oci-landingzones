"""Provider icons for the OCI skill builder. SVGs are embedded for offline export.

Azure assets come from the installed draw.io azure2 library; AWS/GCP use native
vendor stencils bundled in draw.io. Unmapped types retain explicit named boxes.
"""
import base64
from pathlib import Path
from ocidraw import Node, ICON_WRAP, LABEL_POS, _htmltext
ASSETS=Path(__file__).with_name('assets')
AZURE={
 'Microsoft.Network/virtualWans':'Virtual_WANs',
 'Microsoft.Network/virtualHubs':'Virtual_WAN_Hub',
 'Microsoft.Network/virtualHubs/hubRouteTables':'Route_Tables',
 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections':'Connections',
 'Microsoft.Network/expressRouteGateways':'Virtual_Network_Gateways',
 'Microsoft.Network/expressRouteGateways/expressRouteConnections':'Connections',
 'Microsoft.Network/virtualNetworks':'Virtual_Networks',
 'Microsoft.Network/virtualNetworks/subnets':'Subnet',
 'Microsoft.Network/networkSecurityGroups':'Network_Security_Groups',
 'Microsoft.Network/routeTables':'Route_Tables',
 'Microsoft.Network/connections':'Connections',
 'Microsoft.Network/localNetworkGateways':'Local_Network_Gateways',
 'Microsoft.Network/virtualNetworkGateways':'Virtual_Network_Gateways',
 'Microsoft.Network/publicIPAddresses':'Public_IP_Addresses',
 'Microsoft.App/containerApps':'Worker_Container_App',
 'Microsoft.App/managedEnvironments':'Container_App_Environments',
 'Microsoft.OperationalInsights/workspaces':'Log_Analytics_Workspaces',
}
AWS={
 'aws_vpc':('vpc','#8C4FFF'),
 'aws_subnet':('group_subnet','#7AA116'),
 'aws_route_table':('route_table','#8C4FFF'),
 'aws_route':('router','#8C4FFF'),
 'aws_vpn_gateway':('virtual_gateway','#8C4FFF'),
 'aws_security_group':('security_group','#DD344C'),
 'aws_vpc_security_group_ingress_rule':('security_group','#DD344C'),
 'aws_vpc_security_group_egress_rule':('security_group','#DD344C'),
 'AWS::RDS::DBInstance':('rds_mysql_instance','#C925D1'),
 'AWS::EC2::VPC':('vpc','#8C4FFF'),
 'AWS::EC2::Subnet':('group_subnet','#7AA116'),
 'AWS::EC2::RouteTable':('route_table','#8C4FFF'),
 'AWS::EC2::Route':('router','#8C4FFF'),
 'AWS::EC2::InternetGateway':('internet_gateway','#8C4FFF'),
 'AWS::EC2::SecurityGroup':('security_group','#DD344C'),
 'AWS::EC2::TransitGateway':('transit_gateway','#8C4FFF'),
 'AWS::EC2::TransitGatewayAttachment':('transit_gateway_attachment','#8C4FFF'),
 'AWS::EC2::CustomerGateway':('customer_gateway','#8C4FFF'),
 'AWS::EC2::VPNConnection':('vpn_connection','#8C4FFF'),
 'AWS::EC2::FlowLog':('flow_logs','#8C4FFF'),
 'AWS::IAM::Role':('role','#DD344C'),
 'AWS::KMS::Key':('key_management_service','#DD344C'),
 'AWS::Logs::LogGroup':('cloudwatch_logs','#E7157B'),
 'AWS::EC2::Instance':('ec2','#ED7100'),
 'AWS::EC2::LaunchTemplate':('template','#ED7100'),
 'AWS::EC2::EIP':('elastic_ip_address','#8C4FFF'),
}
GCP={
 'google_compute_interconnect_attachment':'partner_interconnect',
 'google_compute_firewall':'cloud_firewall_rules',
 'google_compute_instance':'compute_engine',
 'google_storage_bucket':'cloud_storage',
 'google_compute_network':'cloud_network',
 'google_compute_router':'cloud_router',
 'google_compute_route':'cloud_routes',
 'google_kms_crypto_key':'key_management_service',
}


def available(typ):
 return typ in AZURE or typ in AWS or typ in GCP


def icon(d,typ,cx,cy,parent=None,size=48,label='',label_pos='bottom'):
 """Add a vendor glyph as a registered icon node; no post-export XML edits."""
 if not available(typ): return None
 ident=d._id(); st=ICON_WRAP+LABEL_POS.get(label_pos,'')
 d._vertex(ident,_htmltext(label),st,cx-size/2,cy-size/2,size,size,d._pid(parent))
 if typ in AZURE:
  svg=(ASSETS/'azure'/(AZURE[typ]+'.svg')).read_bytes()
  style='shape=image;imageAspect=1;aspect=fixed;image=data:image/svg+xml,'+base64.b64encode(svg).decode()+';'
 elif typ in AWS:
  shape,color=AWS[typ]
  style=f'shape=mxgraph.aws4.{shape};fillColor={color};strokeColor=none;'
 else:
  style=f'shape=mxgraph.gcp2.{GCP[typ]};fillColor=#4285F4;strokeColor=none;'
 d._vertex(d._id(),'',style,0,0,size,size,ident,' connectable="0"')
 node=Node(d,ident,'icon',cx-size/2,cy-size/2,size,size,parent,label=label,name=typ)
 node.border=False;node.label_pos=label_pos;d.nodes.append(node)
 return node


def box(d,typ,label,x,y,w,h,parent=None,kind='thirdparty_component'):
 """Provider component card; exact type remains in detail-page labels."""
 node=d.group(kind,'',x,y,w,h,parent=parent)
 icon(d,typ,45,h/2,parent=node,size=40)
 d.text(label,85,10,w-100,h-20,parent=node,size=12)
 return node
