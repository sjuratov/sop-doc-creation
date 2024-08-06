param resourceToken string
param location string = resourceGroup().location
param tags object = {}
param deployments array = []
@description('SKU name for OpenAI.')
param openAiSkuName string = 'S0'

// OPEN AI
resource account 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: 'aoai-${resourceToken}'
  location: location
  kind: 'OpenAI'
  sku: {
    name: openAiSkuName
  }
  properties: {
    // disabling the explicit domain name to enable iterative development
    // customSubDomainName: toLower(name)
    publicNetworkAccess: 'Enabled'
  }
  tags: union(tags, { 'azd-service-name': 'aoai-${resourceToken}' })
}

@batchSize(1)
resource deployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = [for deployment in deployments: {
  parent: account
  name: deployment.name
  sku: deployment.sku
  properties: {
    model: deployment.model
  }
}]

resource speechService 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: 'speech-${resourceToken}'
  location: location
  kind: 'SpeechServices'
  sku: {
    name: 'S0'
  } 
  properties: {
    publicNetworkAccess: 'Enabled'
  }
  tags: union(tags, { 'azd-service-name': 'speech-${resourceToken}' })
}

output aoaiEndpoint string = account.properties.endpoint
