@description('Resource Token')
param resourceToken string

@description('Name of the Azure Function App')
param functionAppName string

@description('Location for all resources')
param location string = resourceGroup().location

@description('Name of the storage account')
// param storageAccountName string = '${uniqueString(resourceGroup().id)}funappsa'
param storageAccountName string 

@description('App Ingisghts Connection String')
param appInsightsConnectionString string

param tags object = {}

// [ Referencing existing storage account ]
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: storageAccountName
}
var storageAccountConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=core.windows.net'

// --------------------------------------
// [ FUNCTION APP ]
// Plan (Consumption Plan)
resource functionAppPlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: 'func-plan-${resourceToken}'
  location: location
  kind: 'linux'
  sku: {
    name: 'Y1' 
    tier: 'Dynamic'
  }
  properties: {
    reserved: true // crtical to deploy as Linux
    perSiteScaling: false
  }
  tags: union(tags, {'azd-service-name': functionAppName })
}

// Function App Identity
// resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
//   name: '${functionAppName}-identity'
//   location: location
//   tags: union(tags, { 'azd-service-name': functionAppName })
// }

// Function App
resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp,linux'
  properties: {
    serverFarmId: functionAppPlan.id
    enabled: true
  }
  dependsOn: [
    storageAccount
  ]
 tags: union(tags, {'azd-service-name': 'blobTriggerProcessor' }) // azd-service-name must match the azure.yaml service name
}

// Site Config
resource functionAppSiteConfig 'Microsoft.Web/sites/config@2023-12-01' = {
  parent: functionApp
  name: 'web'
  properties: {
    linuxFxVersion: 'python|3.11'
    pythonVersion: '3.11'
    detailedErrorLoggingEnabled: true
    minTlsVersion: '1.2'
    scmMinTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'  
  }
}

// App Settings
resource functionAppSettings 'Microsoft.Web/sites/config@2023-12-01' = {
  parent: functionApp
  name: 'appsettings'
  properties: {
      SCM_DO_BUILD_DURING_DEPLOYMENT: 'true'
      ENABLE_ORYX_BUILD: 'true'
      APPLICATIONINSIGHTS_CONNECTION_STRING: appInsightsConnectionString
      AzureWebJobsStorage: storageAccountConnectionString
      FUNCTIONS_EXTENSION_VERSION:  '~4'
      FUNCTIONS_WORKER_RUNTIME: 'python'
  }
  dependsOn: [
    storageAccount
  ]
}

output functionAppEndpoint string = functionApp.properties.defaultHostName
