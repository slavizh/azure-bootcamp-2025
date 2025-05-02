import * as types from 'types.bicep'

@description('The storage account configuration.')
param storageAccount types.storageAccount

var networkSettings = {
  allowedIps: []
}

resource storageAccountResource 'Microsoft.Storage/storageAccounts@2024-01-01' = {
  name: storageAccount.name
  location: resourceGroup().location
  kind: storageAccount.?kind ?? 'StorageV2'
  tags: storageAccount.?tags ?? {}
  sku: {
    name: storageAccount.?sku ?? 'Standard_GRS'
  }
  identity: {
    type: storageAccount.?enableSystemAssignedIdentity ?? false
      ? contains(storageAccount, 'userAssignedIdentities')
        ? 'SystemAssigned,UserAssigned'
        : 'SystemAssigned'
      : contains(storageAccount, 'userAssignedIdentities')
        ? 'UserAssigned'
        : 'None'
    userAssignedIdentities: contains(storageAccount, 'userAssignedIdentities')
      ? toObject(
          map(
            storageAccount.userAssignedIdentities!,
            userAssignedIdentity =>
            resourceId(
              userAssignedIdentity.?subscriptionId ?? subscription().subscriptionId,
              userAssignedIdentity.resourceGroupName,
              'Microsoft.ManagedIdentity/userAssignedIdentities',
              userAssignedIdentity.name
            )
          ),
          identity =>
          identity, identity => {}
        )
      : null
  }
  properties: {
    publicNetworkAccess: storageAccount.?networkSettings.?publicNetworkAccess ?? 'Enabled'
    allowBlobPublicAccess: storageAccount.?networkSettings.?allowBlobPublicAccess ?? false
    networkAcls: {
      defaultAction: storageAccount.?networkSettings.?defaultNetworkAction ?? 'Allow'
      bypass: storageAccount.?networkSettings.?bypassTraffic ?? 'None'
      ipRules: contains(storageAccount, 'networkSettings')
        ? map(union(networkSettings, storageAccount.networkSettings!).allowedIps, allowedIp => {
          action: 'Allow'
          value: allowedIp
        })
        : []
    }
  }
}
