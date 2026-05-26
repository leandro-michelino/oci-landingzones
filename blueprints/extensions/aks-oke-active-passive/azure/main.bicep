// Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com

param clusterName string
param dnsPrefix string
param kubernetesVersion string = '1.36'
param nodePoolName string = 'system'
param nodeCount int = 1
param nodeVmSize string = 'Standard_D4ds_v5'
param vnetName string = 'vnet-aks-secondary'
param vnetCidr string = '10.62.0.0/16'
param aksSubnetName string = 'snet-aks-nodes'
param aksSubnetCidr string = '10.62.10.0/24'
param routeTableName string = 'rt-aks-secondary'
param networkSecurityGroupName string = 'nsg-aks-secondary'
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
          priority: 205
          direction: 'Inbound'
        }
      }
      {
        name: 'allow-node-to-node'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: vnetCidr
          destinationAddressPrefix: vnetCidr
          access: 'Allow'
          priority: 210
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource aksSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' = {
  parent: vnet
  name: aksSubnetName
  properties: {
    addressPrefix: aksSubnetCidr
    routeTable: {
      id: routeTable.id
    }
    networkSecurityGroup: {
      id: networkSecurityGroup.id
    }
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2026-01-01' = {
  name: clusterName
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'Base'
    tier: 'Free'
  }
  tags: tags
  properties: {
    dnsPrefix: dnsPrefix
    kubernetesVersion: kubernetesVersion
    agentPoolProfiles: [
      {
        name: nodePoolName
        count: nodeCount
        vmSize: nodeVmSize
        osType: 'Linux'
        mode: 'System'
        type: 'VirtualMachineScaleSets'
        vnetSubnetID: aksSubnet.id
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      loadBalancerSku: 'standard'
      outboundType: 'loadBalancer'
    }
  }
}

output aksClusterId string = aksCluster.id
output aksClusterName string = aksCluster.name
output aksControlPlaneFqdn string = aksCluster.properties.fqdn
output aksNodeResourceGroup string = aksCluster.properties.nodeResourceGroup
output aksVnetId string = vnet.id
output aksSubnetId string = aksSubnet.id
output aksRouteTableId string = routeTable.id
output aksNetworkSecurityGroupId string = networkSecurityGroup.id
