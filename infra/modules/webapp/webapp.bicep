@description('Unique Resource Token')
param resourceToken string

@description('Location for all resources')
param location string = resourceGroup().location

@description('Name of the storage account')
param storageAccountName string

@description('App Ingisghts Connection String')
param appInsightsConnectionString string

param identityName string
param tags object = {}
param azureOpenAIName string
param azureSpeechName string
param azureModelDeployment string

// [ EXISITNG RESOURCES REFERENCE ]
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: storageAccountName
}
var storageAccountConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=core.windows.net'

resource openAIService 'Microsoft.CognitiveServices/accounts@2023-05-01' existing = {
  name: azureOpenAIName
}

resource speechService 'Microsoft.CognitiveServices/accounts@2023-05-01' existing = {
  name: azureSpeechName
}

resource webIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: identityName
}

// --------------------------------------
// [ WEB APP ]
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: 'web-plan-${resourceToken}'
  location: location
  sku: {
    name: 'B2'
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
  tags: union(tags, {'azd-service-name': 'web-app-plan' })
}

resource web 'Microsoft.Web/sites@2022-03-01' = {
  name: 'web-${resourceToken}'
  location: location
  tags: union(tags, { 'azd-service-name': 'web-app' })
  kind: 'app,linux'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'PYTHON|3.11'
      pythonVersion: '3.11'
      appCommandLine: 'python3.11 -m streamlit run streamlit_app.py --server.port 8000 --server.address 0.0.0.0'
      ftpsState: 'Disabled'
      detailedErrorLoggingEnabled: true
      minTlsVersion: '1.2'
      scmMinTlsVersion: '1.2'
      publicNetworkAccess: 'Enabled'
    }
    httpsOnly: true
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${webIdentity.id}': {}
    }
  }

  resource appSettings 'config' = {
    name: 'appsettings'
    properties: {
      SCM_DO_BUILD_DURING_DEPLOYMENT: 'true'
      ENABLE_ORYX_BUILD: 'true'
      APPLICATIONINSIGHTS_CONNECTION_STRING: appInsightsConnectionString
      AzureWebJobsStorage: storageAccountConnectionString
      AZURE_CLIENT_ID: webIdentity.properties.clientId
      // Must match the main bicep outputs for local execution compatibility
      AZURE_OPENAI_ENDPOINT: openAIService.properties.endpoint
      AZURE_OPENAI_DEPLOYMENT_NAME: azureModelDeployment
      // AZURE_OPENAI_KEY: '${openAIService.listKeys().key1}'
      AZURE_SPEECH_RESOURCE_ID: speechService.id
      AZURE_SPEECH_REGION: speechService.location
      // AZURE_SPEECH_KEY: '${speechService.listKeys().key1}'
    }
  }

  resource logs 'config' = {
    name: 'logs'
    properties: {
      applicationLogs: {
        fileSystem: {
          level: 'Verbose'
        }
      }
      detailedErrorMessages: {
        enabled: true
      }
      failedRequestsTracing: {
        enabled: true
      }
      httpLogs: {
        fileSystem: {
          enabled: true
          retentionInDays: 1
          retentionInMb: 35
        }
      }
    }
  }
  dependsOn: [
    storageAccount
  ]
}

output WEB_URI string = 'https://${web.properties.defaultHostName}'
