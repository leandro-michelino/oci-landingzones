// Separately deployed Azure companion. All creation flags default false.
param location string = resourceGroup().location
param costsApproved bool = false
param regionPairVerified bool = false
param addressPlanVerified bool = false
param avsTransitVerified bool = false
param createPrivateCloud bool = false
param createInterconnectCircuit bool = false
param connectAvsToOci bool = false
param enableHcxAddon bool = false
param privateCloudName string = 'avs-vmware'
param privateCloudSku string = 'AV36'
@minValue(3)
@maxValue(16)
param managementClusterSize int = 3
// Illustrative only: replace and validate against all routed site ranges.
param managementNetworkBlock string = '10.180.0.0/22'
param circuitName string = 'er-oci-vmware'
param peeringLocation string = ''
param bandwidthInMbps int = 1000
param hcxOffer string = ''
param hcxManagementNetwork string = ''
param hcxUplinkNetwork string = ''
var approved = costsApproved && regionPairVerified && addressPlanVerified
var createAvs = createPrivateCloud && approved
var createCircuit = createInterconnectCircuit && approved
var connectOci = connectAvsToOci && approved && avsTransitVerified && createInterconnectCircuit

resource avs 'Microsoft.AVS/privateClouds@2024-09-01' = if (createAvs) {
  name: privateCloudName
  location: location
  sku: { name: privateCloudSku }
  properties: {
    internet: 'Disabled'
    managementCluster: { clusterSize: managementClusterSize }
    networkBlock: managementNetworkBlock
  }
}
resource selectedAvs 'Microsoft.AVS/privateClouds@2024-09-01' existing = {
  name: privateCloudName
}
resource oracleCircuit 'Microsoft.Network/expressRouteCircuits@2024-05-01' = if (createCircuit) {
  name: circuitName
  location: location
  sku: { name: 'Standard_MeteredData', tier: 'Standard', family: 'MeteredData' }
  properties: {
    allowClassicOperations: false
    globalReachEnabled: avsTransitVerified
    serviceProviderProperties: {
      serviceProviderName: 'Oracle Cloud FastConnect'
      peeringLocation: peeringLocation
      bandwidthInMbps: bandwidthInMbps
    }
  }
}
resource oracleAuthorization 'Microsoft.Network/expressRouteCircuits/authorizations@2024-05-01' = if (connectOci) {
  parent: oracleCircuit
  name: 'avs-global-reach'
}
resource avsOciConnection 'Microsoft.AVS/privateClouds/globalReachConnections@2024-09-01' = if (connectOci) {
  parent: selectedAvs
  name: 'oci-interconnect'
  properties: {
    authorizationKey: oracleAuthorization!.properties.authorizationKey
    peerExpressRouteCircuit: oracleCircuit.id
  }
  dependsOn: [avs]
}
resource hcx 'Microsoft.AVS/privateClouds/addons@2024-09-01' = if (enableHcxAddon && approved) {
  parent: selectedAvs
  name: 'HCX'
  properties: {
    addonType: 'HCX'
    offer: hcxOffer
    managementNetwork: hcxManagementNetwork
    uplinkNetwork: hcxUplinkNetwork
  }
  dependsOn: [avs]
}
output effectiveFlags object = { createAvs: createAvs, createCircuit: createCircuit, connectOci: connectOci, hcx: enableHcxAddon && approved }
// No service keys, authorization keys, administrator passwords or runtime reference() outputs.
output selectedPrivateCloudId string = selectedAvs.id
output interconnectCircuitId string = createCircuit ? oracleCircuit.id : ''
