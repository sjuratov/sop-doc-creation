@description('Location for all resources')
param location string = resourceGroup().location
param logAnalyticsName string
param resourceToken string
param tags object = {}

// Log Analytics
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: logAnalyticsName
  location: location
  properties: any({
    retentionInDays: 30
    features: {
      searchVersion: 1
    }
    sku: {
      name: 'PerGB2018'
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  })
  tags: union(tags, { 'azd-service-name': logAnalyticsName })
}

// Application Insights
var appInsightsName = 'insights-${resourceToken}'
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
  tags: union(tags, {'azd-service-name': appInsightsName })
}

output appInsightsConnectionString string = appInsights.properties.ConnectionString
