targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources (filtered on available regions for Azure Open AI Service).')
@allowed([
  'westeurope'
  'southcentralus'
  'australiaeast'
  'canadaeast'
  'eastus'
  'eastus2'
  'francecentral'
  'japaneast'
  'northcentralus'
  'swedencentral'
  'switzerlandnorth'
  'uksouth'
])
param location string


@description('Name of the resource group. Leave blank to use default naming conventions.')
param resourceGroupName string = ''

@description('Name of the Storage resource. Leave blank to use default naming conventions.')
param storageAccountName string = ''

@description('Tags to be applied to resources.')
param tags object = { 'azd-env-name': environmentName }

// Load abbreviations from JSON file
var abbrs = loadJsonContent('./abbreviations.json')
// Generate a unique token for resources
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))

// Organize resources in a resource group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: !empty(resourceGroupName) ? resourceGroupName : '${abbrs.resourcesResourceGroups}${environmentName}'
  location: location
  tags: tags
}


// ------------------------
// [ Array of OpenAI Model deployments ]
param aoaiGpt4ModelName string= 'gpt-4o'
param aoaiGpt4ModelVersion string = '2024-05-13'

param aoaiEmbeddingsName string = 'text-embedding-ada-002'
param aoaiEmbeddingsVersion string  = '2'

param deployments array = [
  {
    name:  '${aoaiGpt4ModelName}-${aoaiGpt4ModelVersion}'
    model: {
      format: 'OpenAI'
      name: aoaiGpt4ModelName
      version: aoaiGpt4ModelVersion
    }
    sku: {
      name: 'Standard'
      capacity: 30
    }
  }
  {
    name: aoaiEmbeddingsName
    model: {
      format: 'OpenAI'
      name: aoaiEmbeddingsName
      version: aoaiEmbeddingsVersion
    }
    sku: {
      name: 'Standard'
      capacity: 120
    }
  }
]

module aiServices 'modules/ai/cognitiveservices.bicep' = {
  name: 'aiServices'
  scope: resourceGroup
  params: {
    resourceToken: resourceToken
    tags: tags
    deployments: deployments
  }
}

module storageAccount './modules/storage/storageaccount.bicep' = {
  name: 'storage'
  scope: resourceGroup
  params: {
    location: location
    tags: tags
    storageAccountName: !empty(storageAccountName) ? storageAccountName : 'stor${resourceToken}'
  }
}

module monitoring 'modules/monitoring/monitor.bicep' = {
  name: 'monitor'
  scope: resourceGroup
  params: {
    logAnalyticsName: '${abbrs.operationalInsightsWorkspaces}${resourceToken}'
    resourceToken: resourceToken
    tags: tags
  }
}

module functionApp 'modules/functionapp/functionapp.bicep' = {
  name: 'functionApp'
  scope: resourceGroup
  params: {
    storageAccountName: storageAccount.outputs.storageAccountName
    functionAppName: 'funcapp-${resourceToken}'
    appInsightsConnectionString: monitoring.outputs.appInsightsConnectionString
    tags: tags
  }
}

output AZURE_OPENAI_ENDPOINT string = aiServices.outputs.aoaiEndpoint
output AZURE_OPENAI_KEY      string = aiServices.outputs.aoaiKey1
output AZURE_SPEECH_KEY      string = aiServices.outputs.speechKey
output AZURE_SPEECH_REGION   string = aiServices.outputs.speechRegion
