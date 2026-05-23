// Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com

param virtualWanName string = 'vwan-oci-azure-transit'
param virtualHubName string = 'vhub-oci-azure-transit'
param virtualHubAddressPrefix string = '10.88.255.0/24'
param routeTableName string = 'rt-vhub-oci-transit'

param vnetName string = 'vnet-oci-azure-transit'
param vnetCidr string = '10.88.0.0/16'
param workloadSubnetName string = 'snet-transit-workload'
param workloadSubnetCidr string = '10.88.10.0/24'
param gatewaySubnetCidr string = '10.88.250.0/27'
param networkSecurityGroupName string = 'nsg-oci-azure-transit'
param workloadRouteTableName string = 'rt-oci-azure-transit-workload'

param deployVpnGateway bool = true
param vpnGatewayPublicIpName string = 'pip-oci-azure-transit-vng'
param vpnGatewayName string = 'vng-oci-azure-transit'
param localNetworkGatewayName string = 'lng-oci-drg-primary'
param vpnConnectionName string = 'conn-azure-oci-transit-fallback'

param ociCpePublicIp string = '198.51.100.10'
param ociAddressPrefixes array = [
  '10.58.0.0/16'
]
param azureAsn int = 65515
param ociAsn int = 31898
param fallbackSharedKey string = 'replace-with-secure-key'
param tags object = {}

resource virtualWan 'Microsoft.Network/virtualWans@2024-05-01' = {
  name: virtualWanName
  location: resourceGroup().location
  tags: tags
  properties: {
    type: 'Standard'
    allowBranchToBranchTraffic: true
    disableVpnEncryption: false
  }
}

resource virtualHub 'Microsoft.Network/virtualHubs@2024-05-01' = {
  name: virtualHubName
  location: resourceGroup().location
  tags: tags
  properties: {
    addressPrefix: virtualHubAddressPrefix
    virtualWan: {
      id: virtualWan.id
    }
  }
}

resource vhubRouteTable 'Microsoft.Network/virtualHubs/hubRouteTables@2024-05-01' = {
  parent: virtualHub
  name: routeTableName
  properties: {
    labels: [
      'oci-transit'
    ]
    routes: []
  }
}

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

resource workloadRouteTable 'Microsoft.Network/routeTables@2024-05-01' = {
  name: workloadRouteTableName
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

resource workloadSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' = {
  parent: vnet
  name: workloadSubnetName
  properties: {
    addressPrefix: workloadSubnetCidr
    routeTable: {
      id: workloadRouteTable.id
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

resource vhubConnection 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2024-05-01' = {
  parent: virtualHub
  name: 'conn-vhub-to-workload-vnet'
  properties: {
    remoteVirtualNetwork: {
      id: vnet.id
    }
    enableInternetSecurity: false
    routingConfiguration: {
      associatedRouteTable: {
        id: vhubRouteTable.id
      }
      propagatedRouteTables: {
        labels: [
          'oci-transit'
        ]
        ids: []
      }
    }
  }
}

resource vpnGatewayPublicIp 'Microsoft.Network/publicIPAddresses@2024-05-01' = if (deployVpnGateway) {
  name: vpnGatewayPublicIpName
  location: resourceGroup().location
  tags: tags
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
      name: 'VpnGw1'
      tier: 'VpnGw1'
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

output azureVirtualWanId string = virtualWan.id
output azureVirtualHubId string = virtualHub.id
output azureVirtualHubRouteTableId string = vhubRouteTable.id
output azureVirtualHubConnectionId string = vhubConnection.id
output azureWorkloadVnetId string = vnet.id
output azureWorkloadSubnetId string = workloadSubnet.id
output azureWorkloadRouteTableId string = workloadRouteTable.id
output azureNetworkSecurityGroupId string = networkSecurityGroup.id
output azureVpnGatewayId string = deployVpnGateway ? vpnGateway.id : ''
output azureVpnConnectionId string = deployVpnGateway ? vpnConnection.id : ''
output azureVpnGatewayPublicIp string = deployVpnGateway ? vpnGatewayPublicIp.properties.ipAddress : ''
