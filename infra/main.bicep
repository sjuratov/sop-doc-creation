targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

// Commenting out the regions where the deployment failed for one or another reason
@minLength(1)
@description('Primary location for all resources (filtered on available regions for Azure Open AI Service).')
@allowed([
  'westeurope'
  'southcentralus'
  'australiaeast'
  'canadaeast'
  // 'eastus'
  'eastus2'
  'francecentral'
  'japaneast'
  'northcentralus'
  // 'swedencentral'
  'switzerlandnorth'
  // 'uksouth'
])
param location string


@description('Name of the resource group. Leave blank to use default naming conventions.')
param resourceGroupName string = ''

@description('Name of the Storage resource. Leave blank to use default naming conventions.')
param storageAccountName string = ''

@description('Tags to be applied to resources.')
param tags object = { 'azd-env-name': environmentName }

@description('Whether the deployment is running on GitHub Actions')
param runningOnGh string = ''

@description('Whether the deployment is running on Azure DevOps Pipeline')
param runningOnAdo string = ''

@description('Id of the user or app to assign application roles')
param principalId string = ''
var principalType = empty(runningOnGh) && empty(runningOnAdo) ? 'User' : 'ServicePrincipal'

param openAiServiceName string = ''
param speechServiceName string = ''

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
// [ User Assigned Identity for WebApp to avoid circular dependency ]
module webIdentity './modules/webapp/identity.bicep' = {
  name: 'webIdentity'
  scope: resourceGroup
  params: {
    location: location
    identityName: 'webapp-${resourceToken}'
  }
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
      name: 'GlobalStandard'
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

var openAiDeployments = [
  {
    name:  '${aoaiGpt4ModelName}-${aoaiGpt4ModelVersion}'
    model: {
      format: 'OpenAI'
      name: aoaiGpt4ModelName
      version: aoaiGpt4ModelVersion
    }
    sku: {
      name: 'GlobalStandard'
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

// https://azure.github.io/Azure-Verified-Modules/specs/bicep/
// https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations
module openAi 'br/public:avm/res/cognitive-services/account:0.8.0' = {
  name: 'openai'
  scope: resourceGroup
  params: {
    name: !empty(openAiServiceName) ? openAiServiceName : 'oai-${resourceToken}'
    location: location
    tags: union(tags, { 'azd-service-name': 'aoai-${tags['azd-env-name']}' })
    kind: 'OpenAI'
    customSubDomainName: !empty(openAiServiceName) ? openAiServiceName : 'oai-${resourceToken}'
    sku: 'S0'
    deployments: openAiDeployments
    disableLocalAuth: false
    publicNetworkAccess: 'Enabled'
    networkAcls: {}
    roleAssignments: [
      {
        roleDefinitionIdOrName: 'Cognitive Services OpenAI User'
        principalId: principalId
        principalType: principalType
      }
      {
        roleDefinitionIdOrName: 'Cognitive Services OpenAI User'
        principalId: webIdentity.outputs.principalId
        principalType: 'ServicePrincipal'
      }
    ]
  }
}


module speech 'br/public:avm/res/cognitive-services/account:0.8.0' = {
  name: 'speech'
  scope: resourceGroup
  params: {
    name: !empty(speechServiceName) ? speechServiceName : 'spch-${resourceToken}'
    location: location
    tags: union(tags, { 'azd-service-name': 'speech-${tags['azd-env-name']}' })
    kind: 'SpeechServices'
    sku: 'S0'
    disableLocalAuth: false
    publicNetworkAccess: 'Enabled'
    networkAcls: {}
    roleAssignments: [
      {
        roleDefinitionIdOrName: 'Cognitive Services Speech User'
        principalId: principalId
        principalType: principalType
      }
      {
        roleDefinitionIdOrName: 'Cognitive Services OpenAI User'
        principalId: webIdentity.outputs.principalId
        principalType: 'ServicePrincipal'
      }
    ]
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

module webApp 'modules/webapp/webapp.bicep' = {
  name: 'webapp'
  scope: resourceGroup
  params: {
    storageAccountName: storageAccount.outputs.storageAccountName
    appInsightsConnectionString: monitoring.outputs.appInsightsConnectionString
    tags: tags
    resourceToken: resourceToken
    azureOpenAIName: openAi.outputs.name
    azureModelDeployment: deployments[0].name
    azureSpeechName: speech.outputs.name
    identityName: webIdentity.outputs.name
  }
}

output AZURE_OPENAI_ENDPOINT string = openAi.outputs.endpoint
output AZURE_OPENAI_ACCOUNT_NAME string = openAi.outputs.name
output AZURE_OPENAI_DEPLOYMENT_NAME string = deployments[0].name

output AZURE_SPEECH_REGION   string = speech.outputs.location
output AZURE_SPEECH_ACCOUNT_NAME  string = speech.outputs.name
output AZURE_SPEECH_RESOURCE_ID string = speech.outputs.resourceId

output AZURE_WEBAPP_ENDPOINT string = webApp.outputs.WEB_URI
