// Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com

param vnetName string = 'vnet-oci-azure-connectivity'
param vnetCidr string = '10.88.0.0/16'
param workloadSubnetName string = 'snet-connectivity-workload'
param workloadSubnetCidr string = '10.88.10.0/24'
param gatewaySubnetCidr string = '10.88.250.0/27'
param routeTableName string = 'rt-oci-azure-connectivity'
param networkSecurityGroupName string = 'nsg-oci-azure-connectivity'

param deployVpnGateway bool = true
param vpnGatewayPublicIpName string = 'pip-oci-azure-connectivity-vng'
param vpnGatewayPublicIpZones array = [
  '1'
  '2'
  '3'
]
param vpnGatewayName string = 'vng-oci-azure-connectivity'
param localNetworkGatewayName string = 'lng-oci-primary'
param vpnConnectionName string = 'conn-azure-oci-fallback'

param ociCpePublicIp string = '198.51.100.10'
param ociAddressPrefixes array = [
  '10.58.0.0/16'
]
param azureAsn int = 65515
param ociAsn int = 31898
param fallbackSharedKey string = 'replace-with-secure-key'
param tags object = {}

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: vnetName
  location: resourceGroup().location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetCidr
      ]
    }
  }
}

resource routeTable 'Microsoft.Network/routeTables@2024-05-01' = {
  name: routeTableName
  location: resourceGroup().location
  tags: tags
  properties: {
    disableBgpRoutePropagation: false
    routes: [
      {
        name: 'default-internet'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'Internet'
        }
      }
    ]
  }
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: networkSecurityGroupName
  location: resourceGroup().location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'allow-https-inbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 200
          direction: 'Inbound'
        }
      }
      {
        name: 'allow-http-inbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 210
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource workloadSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' = {
  parent: vnet
  name: workloadSubnetName
  properties: {
    addressPrefix: workloadSubnetCidr
    routeTable: {
      id: routeTable.id
    }
    networkSecurityGroup: {
      id: networkSecurityGroup.id
    }
  }
}

resource gatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' = if (deployVpnGateway) {
  parent: vnet
  name: 'GatewaySubnet'
  properties: {
    addressPrefix: gatewaySubnetCidr
  }
}

resource vpnGatewayPublicIp 'Microsoft.Network/publicIPAddresses@2024-05-01' = if (deployVpnGateway) {
  name: vpnGatewayPublicIpName
  location: resourceGroup().location
  tags: tags
  zones: vpnGatewayPublicIpZones
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource vpnGateway 'Microsoft.Network/virtualNetworkGateways@2024-05-01' = if (deployVpnGateway) {
  name: vpnGatewayName
  location: resourceGroup().location
  tags: tags
  properties: {
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    enableBgp: true
    activeActive: false
    sku: {
      name: 'VpnGw1AZ'
      tier: 'VpnGw1AZ'
    }
    ipConfigurations: [
      {
        name: 'default'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: vpnGatewayPublicIp.id
          }
          subnet: {
            id: gatewaySubnet.id
          }
        }
      }
    ]
    bgpSettings: {
      asn: azureAsn
      bgpPeeringAddress: '10.88.250.4'
    }
  }
}

resource localNetworkGateway 'Microsoft.Network/localNetworkGateways@2024-05-01' = if (deployVpnGateway) {
  name: localNetworkGatewayName
  location: resourceGroup().location
  tags: tags
  properties: {
    gatewayIpAddress: ociCpePublicIp
    localNetworkAddressSpace: {
      addressPrefixes: ociAddressPrefixes
    }
    bgpSettings: {
      asn: ociAsn
      bgpPeeringAddress: '169.254.21.2'
    }
  }
}

resource vpnConnection 'Microsoft.Network/connections@2024-05-01' = if (deployVpnGateway) {
  name: vpnConnectionName
  location: resourceGroup().location
  tags: tags
  properties: {
    connectionType: 'IPsec'
    virtualNetworkGateway1: {
      id: vpnGateway.id
    }
    localNetworkGateway2: {
      id: localNetworkGateway.id
    }
    routingWeight: 20
    enableBgp: true
    sharedKey: fallbackSharedKey
  }
}

output azureWorkloadVnetId string = vnet.id
output azureWorkloadSubnetId string = workloadSubnet.id
output azureRouteTableId string = routeTable.id
output azureNetworkSecurityGroupId string = networkSecurityGroup.id
output azureVpnGatewayId string = deployVpnGateway ? vpnGateway.id : ''
output azureVpnConnectionId string = deployVpnGateway ? vpnConnection.id : ''
output azureVpnGatewayPublicIp string = deployVpnGateway ? vpnGatewayPublicIp.properties.ipAddress : ''
