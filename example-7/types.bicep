@export()
type storageAccount = {
  @description('The name of the storage account. May contain numbers and lowercase letters only. Must be unique within Azure.')
  @minLength(3)
  @maxLength(24)
  name: string
  @description('The kind of storage account. Default value is StorageV2.')
  kind: 'BlobStorage' | 'BlockBlobStorage' | 'FileStorage' | 'Storage' | 'StorageV2'?
  @description('Tags to be applied to the storage account.')
  tags: tags?
  @description('The SKU of the storage account. Default value is Standard_GRS.')
  sku: 'PremiumV2_LRS' | 'PremiumV2_ZRS' | 'Premium_LRS' | 'Premium_ZRS' | 'StandardV2_GRS' | 'StandardV2_GZRS' | 'StandardV2_LRS' | 'StandardV2_ZRS'
    | 'Standard_GRS' | 'Standard_GZRS' | 'Standard_LRS' | 'Standard_RAGRS' | 'Standard_RAGZRS' | 'Standard_ZRS'?
  @description('Enables the system assigned identity for the storage account. Default value is false.')
  enableSystemAssignedIdentity: bool?
  @description('User assigned identities for the storage account.')
  userAssignedIdentities: userAssignedIdentity[]?
  @description('Configure network settings.')
  networkSettings: networkSettings?
}

type tags = {
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

type networkSettings = {
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
