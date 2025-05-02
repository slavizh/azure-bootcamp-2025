param bastionHostName string
@allowed([
  'Developer'
  'Standard'
])
param skuName string
param networkAcls object = {}


resource bastion 'Microsoft.Network/bastionHosts@2024-05-01' = {
  name: bastionHostName
  location: resourceGroup().location
  sku: {
    name: skuName
  }
  properties: {
    ipConfigurations: skuName == 'Standard' ? [
      {
        name: 'ipConf'
        id: resourceId('Microsoft.Network/bastionHosts/bastionHostIpConfigurations', bastionHostName, 'ipConf')
        properties: {
          publicIPAddress: {
              id: ''
            }
          subnet: {
            id: ''
          }
        }
      }
    ] : []
    ...skuName == 'Developer' ? {
      networkAcls: networkAcls
    } : {}
    ...skuName == 'Standard' ? {
      enableKerberos: true
      enableFileCopy: true
      disableCopyPaste: true
      enableIpConnect: true
      enableShareableLink: true
      enableTunneling: true
    } : {}
  }
}
