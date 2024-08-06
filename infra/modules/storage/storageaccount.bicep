param storageAccountName string
param location string = resourceGroup().location
param tags object = {}

@description('Storage Account type')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
])
param storageAccountType string = 'Standard_LRS'

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  kind: 'StorageV2'
  location: location
  sku: {
    name: storageAccountType
  }
  properties: {
    allowBlobPublicAccess: true
    allowCrossTenantReplication: false
    allowSharedKeyAccess: true
    supportsHttpsTrafficOnly: true
    publicNetworkAccess: 'Enabled'
    accessTier: 'Hot'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
  }
  tags: union(tags, { 'azd-service-name': storageAccountName })
}

// blob container - the name must match the declaration in the function binding in python
resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-05-01' = {
  name: '${storageAccountName}/default/inbox'
  dependsOn: [
    storageAccount
  ]
}

output storageAccountName string = storageAccount.name
