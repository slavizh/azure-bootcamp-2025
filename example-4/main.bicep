type storageAccountType = {
  @description('The name of the storage account. May contain numbers and lowercase letters only. Must be unique within Azure.')
  @minLength(3)
  @maxLength(24)
  name: string
  @description('The kind of storage account. Default value is StorageV2.')
  kind: 'BlobStorage' | 'BlockBlobStorage' | 'FileStorage' | 'Storage' | 'StorageV2'?
  @description('Tags to be applied to the storage account.')
  tags: tagsType?
  @description('The SKU of the storage account. Default value is Standard_GRS.')
  sku: 'PremiumV2_LRS' | 'PremiumV2_ZRS' | 'Premium_LRS' | 'Premium_ZRS' | 'StandardV2_GRS' | 'StandardV2_GZRS' | 'StandardV2_LRS' | 'StandardV2_ZRS'
    | 'Standard_GRS' | 'Standard_GZRS' | 'Standard_LRS' | 'Standard_RAGRS' | 'Standard_RAGZRS' | 'Standard_ZRS'?
  @description('Enables the system assigned identity for the storage account. Default value is false.')
  enableSystemAssignedIdentity: bool?
  @description('User assigned identities for the storage account.')
  userAssignedIdentities: userAssignedIdentity[]?
  @description('Configure network settings.')
  networkSettings: networkSettingsType?
}

type tagsType = {
  @description('The value of the tag.')
  *: string
}

type userAssignedIdentity = {
  @description('The subscription ID where the user assigned identity is located. Default value is current subscription for deployment.')
  subscriptionId: string?
  @description('The name of the resource group where the user assigned identity is located.')
  resourceGroupName: string
  @description('The name of the user assigned identity.')
  name: string
}

type networkSettingsType = {
  @description('Configures public network access. Default value is Enabled.')
  publicNetworkAccess: 'Disabled' | 'Enabled' | 'SecuredByPerimeter'?
  @description('Allows containers to be configured with public access. Default value is false.')
  allowBlobPublicAccess: bool?
  @description('''Bypasses traffic for Logging/Metrics/AzureServices.
    Possible values are any combination of Logging|Metrics|AzureServices (For example, "Logging, Metrics"), or None to bypass none of those traffics.
    Default value is None.''')
  bypassTraffic: string?
  @description('Sets the default action for network access. Default value is Allow.')
  defaultNetworkAction: 'Allow' | 'Deny'?
  @description('IPs or IP ranges in CIDR format to be allowed access to the storage account.')
  allowedIps: string[]?
}

@description('The storage account configuration.')
param storageAccount storageAccountType

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
