// Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com

param clusterName string
param dnsPrefix string
param nodePoolName string = 'system'
param nodeCount int = 1
param nodeVmSize string = 'Standard_D4ds_v5'
param tags object = {}

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
    agentPoolProfiles: [
      {
        name: nodePoolName
        count: nodeCount
        vmSize: nodeVmSize
        osType: 'Linux'
        mode: 'System'
        type: 'VirtualMachineScaleSets'
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      loadBalancerSku: 'standard'
    }
  }
}

output aksClusterId string = aksCluster.id
output aksClusterName string = aksCluster.name
output aksControlPlaneFqdn string = aksCluster.properties.fqdn
output aksNodeResourceGroup string = aksCluster.properties.nodeResourceGroup
