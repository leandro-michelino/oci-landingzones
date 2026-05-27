
param logAnalyticsWorkspaceName string
param managedEnvironmentName string
param containerAppName string
param helloWorldImage string = 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
param vnetName string = 'vnet-oci-azure-ai-gateway'
param vnetCidr string = '10.92.0.0/16'
param containerAppSubnetName string = 'snet-oci-azure-ai-gateway'
param containerAppSubnetCidr string = '10.92.10.0/23'
param routeTableName string = 'rt-oci-azure-ai-gateway'
param networkSecurityGroupName string = 'nsg-oci-azure-ai-gateway'
param openAiAccountName string
param openAiCustomSubdomain string
param openAiSkuName string = 'S0'
param deployOpenAiModel bool = false
param openAiModelDeploymentName string = 'gpt4omini'
param openAiModelName string = 'gpt-4o-mini'
param openAiModelFormat string = 'OpenAI'
param openAiModelVersion string = '2024-07-18'
param openAiModelCapacity int = 20
param apimServiceName string
param apimPublisherName string = 'Platform Team'
param apimPublisherEmail string = 'platform@example.com'
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
      {
        name: 'allow-vnet-eastwest'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: vnetCidr
          destinationAddressPrefix: vnetCidr
          access: 'Allow'
          priority: 220
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource containerAppSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' = {
  parent: vnet
  name: containerAppSubnetName
  properties: {
    addressPrefix: containerAppSubnetCidr
    routeTable: {
      id: routeTable.id
    }
    networkSecurityGroup: {
      id: networkSecurityGroup.id
    }
    delegations: [
      {
        name: 'container-apps-delegation'
        properties: {
          serviceName: 'Microsoft.App/environments'
        }
      }
    ]
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsWorkspaceName
  location: resourceGroup().location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

resource managedEnvironment 'Microsoft.App/managedEnvironments@2025-02-02-preview' = {
  name: managedEnvironmentName
  location: resourceGroup().location
  tags: tags
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: listKeys(logAnalyticsWorkspace.id, logAnalyticsWorkspace.apiVersion).primarySharedKey
      }
    }
    vnetConfiguration: {
      infrastructureSubnetId: containerAppSubnet.id
      internal: false
    }
  }
}

resource containerApp 'Microsoft.App/containerApps@2025-01-01' = {
  name: containerAppName
  location: resourceGroup().location
  tags: tags
  properties: {
    managedEnvironmentId: managedEnvironment.id
    configuration: {
      ingress: {
        external: true
        targetPort: 80
        allowInsecure: false
        traffic: [
          {
            latestRevision: true
            weight: 100
          }
        ]
      }
    }
    template: {
      containers: [
        {
          name: 'hello-world'
          image: helloWorldImage
          resources: {
            cpu: json('0.5')
            memory: '1Gi'
          }
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 2
      }
    }
  }
}

resource openAiAccount 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: openAiAccountName
  location: resourceGroup().location
  tags: tags
  kind: 'OpenAI'
  sku: {
    name: openAiSkuName
  }
  properties: {
    customSubDomainName: openAiCustomSubdomain
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
  }
}

resource openAiModelDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = if (deployOpenAiModel) {
  parent: openAiAccount
  name: openAiModelDeploymentName
  sku: {
    name: 'Standard'
    capacity: openAiModelCapacity
  }
  properties: {
    model: {
      format: openAiModelFormat
      name: openAiModelName
      version: openAiModelVersion
    }
    raiPolicyName: 'Microsoft.DefaultV2'
  }
}

resource apiManagement 'Microsoft.ApiManagement/service@2022-08-01' = {
  name: apimServiceName
  location: resourceGroup().location
  tags: tags
  sku: {
    name: 'Consumption'
    capacity: 0
  }
  properties: {
    publisherName: apimPublisherName
    publisherEmail: apimPublisherEmail
    publicNetworkAccess: 'Enabled'
  }
}

output azureOpenAiAccountId string = openAiAccount.id
output azureOpenAiEndpoint string = openAiAccount.properties.endpoint
output azureOpenAiModelDeploymentId string = deployOpenAiModel ? openAiModelDeployment.id : ''
output azureApiManagementGatewayUrl string = 'https://${apiManagement.name}.azure-api.net'
output azureHelloWorldEndpoint string = 'https://${containerApp.properties.configuration.ingress.fqdn}'
output azureVnetId string = vnet.id
output azureSubnetId string = containerAppSubnet.id
output azureRouteTableId string = routeTable.id
output azureNetworkSecurityGroupId string = networkSecurityGroup.id
