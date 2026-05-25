// Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com

param virtualWanName string = 'vwan-oci-hub-spoke'
param virtualHubName string = 'vhub-oci-hub-spoke'
param virtualHubAddressPrefix string = '10.88.255.0/24'
param routeTableName string = 'rt-vhub-oci-transit'

param deployExpressRouteGateway bool = true
param expressRouteGatewayName string = 'ergw-oci-hub-spoke'
param expressRouteGatewayScaleUnits int = 1
param expressRouteConnectionName string = 'conn-ergw-to-oci-fastconnect'
param expressRouteCircuitPeeringId string = ''
param expressRouteAuthorizationKey string = ''

param ociAddressPrefixes array = [
  '10.0.0.0/16'
  '10.1.0.0/16'
]

param spokeVnets array = [
  {
    key: 'app1'
    name: 'vnet-oci-spoke-app1'
    addressPrefixes: [
      '10.88.10.0/24'
    ]
    subnetName: 'snet-workload'
    subnetPrefix: '10.88.10.0/24'
    networkSecurityGroupName: 'nsg-oci-spoke-app1'
    connectionName: 'conn-vhub-to-app1'
    connectedOciSpokes: [
      'app1'
    ]
  }
]

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

resource expressRouteGateway 'Microsoft.Network/expressRouteGateways@2024-05-01' = if (deployExpressRouteGateway) {
  name: expressRouteGatewayName
  location: resourceGroup().location
  tags: tags
  properties: {
    virtualHub: {
      id: virtualHub.id
    }
    autoScaleConfiguration: {
      bounds: {
        min: expressRouteGatewayScaleUnits
        max: expressRouteGatewayScaleUnits
      }
    }
  }
}

resource expressRouteConnection 'Microsoft.Network/expressRouteGateways/expressRouteConnections@2024-05-01' = if (deployExpressRouteGateway && !empty(expressRouteCircuitPeeringId)) {
  parent: expressRouteGateway
  name: expressRouteConnectionName
  properties: {
    expressRouteCircuitPeering: {
      id: expressRouteCircuitPeeringId
    }
    authorizationKey: expressRouteAuthorizationKey
    routingWeight: 100
    enableInternetSecurity: false
  }
}

resource networkSecurityGroups 'Microsoft.Network/networkSecurityGroups@2024-05-01' = [for spokeVnet in spokeVnets: {
  name: spokeVnet.networkSecurityGroupName
  location: resourceGroup().location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'allow-oci-private-inbound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefixes: ociAddressPrefixes
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 200
          direction: 'Inbound'
        }
      }
    ]
  }
}]

resource vnets 'Microsoft.Network/virtualNetworks@2024-05-01' = [for spokeVnet in spokeVnets: {
  name: spokeVnet.name
  location: resourceGroup().location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: spokeVnet.addressPrefixes
    }
  }
}]

resource workloadSubnets 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' = [for (spokeVnet, i) in spokeVnets: {
  parent: vnets[i]
  name: spokeVnet.subnetName
  properties: {
    addressPrefix: spokeVnet.subnetPrefix
    networkSecurityGroup: {
      id: networkSecurityGroups[i].id
    }
  }
}]

resource vhubConnections 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2024-05-01' = [for (spokeVnet, i) in spokeVnets: {
  parent: virtualHub
  name: spokeVnet.connectionName
  properties: {
    remoteVirtualNetwork: {
      id: vnets[i].id
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
}]

output azureVirtualWanId string = virtualWan.id
output azureVirtualHubId string = virtualHub.id
output azureVirtualHubRouteTableId string = vhubRouteTable.id
output azureExpressRouteGatewayId string = deployExpressRouteGateway ? expressRouteGateway.id : ''
output azureExpressRouteConnectionId string = deployExpressRouteGateway && !empty(expressRouteCircuitPeeringId) ? expressRouteConnection.id : ''
output azureVnetPeerings array = [for (spokeVnet, i) in spokeVnets: {
  key: spokeVnet.key
  vnetId: vnets[i].id
  subnetId: workloadSubnets[i].id
  vhubConnectionId: vhubConnections[i].id
  networkSecurityGroupId: networkSecurityGroups[i].id
  addressPrefixes: spokeVnet.addressPrefixes
  connectedOciSpokes: spokeVnet.connectedOciSpokes
}]
output ociAddressPrefixes array = ociAddressPrefixes
