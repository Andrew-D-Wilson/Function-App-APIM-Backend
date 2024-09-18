/**********************************
Bicep Template: Application Deploy
        Author: Andrew Wilson
***********************************/

targetScope = 'resourceGroup'

// ** Parameters **
// ****************

@description('A prefix used to identify the application resources')
param applicationPrefixName string

@description('The name of the application used for tags')
param applicationName string

@description('The location that the resources will be deployed to - defaulting to the resource group location')
param location string = resourceGroup().location

@description('The environment that the resources are being deployed to')
@allowed([
  'dev'
  'test'
  'prod'
])
param env string = 'dev'

// ** Variables **
// ***************

var applicationKeyVaultName = '${applicationPrefixName}${env}kv'
var funcApplicationAppServicePlanName = '${applicationPrefixName}${env}asp'
var funcStorageAccountName = '${applicationPrefixName}${env}st'
var applicationFunctionAppName = '${applicationPrefixName}${env}func'

var isProduction = env == 'prod'

// ** Resources **
// ***************

@description('Deploy the Application Specific Key Vault')
resource applicationKeyVaultDeploy 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: applicationKeyVaultName
  location: location
  tags: {
    Application: applicationName
    Environment: env
    Version: deployment().properties.template.contentVersion
  }
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenant().tenantId
    enableRbacAuthorization: true
    enableSoftDelete: isProduction
  }
}

@description('Deploy the App Service Plan used for Function App')
resource funcAppServicePlanDeploy 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: funcApplicationAppServicePlanName
  location: location
  tags: {
    Application: applicationName
    Environment: env
    Version: deployment().properties.template.contentVersion
  }
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {}
}

@description('Deploy the Storage Account used for Function App')
resource funcStorageAccountDeploy 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: funcStorageAccountName
  location: location
  tags: {
    Application: applicationName
    Environment: env
    Version: deployment().properties.template.contentVersion
  }
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    defaultToOAuthAuthentication: true
  }
}

@description('Deploy the Application Function App')
resource applicationFunctionAppDeploy 'Microsoft.Web/sites@2023-12-01' = {
  name: applicationFunctionAppName
  location: location
  tags: {
    Application: applicationName
    Environment: env
    Version: deployment().properties.template.contentVersion
  }
  kind: 'functionapp'
  properties: {
    serverFarmId: funcAppServicePlanDeploy.id
    publicNetworkAccess: 'Enabled'
    httpsOnly: true
  }
  resource config 'config@2022-09-01' = {
    name: 'appsettings'
    properties: {
      FUNCTIONS_EXTENSION_VERSION: '~4'
      FUNCTIONS_WORKER_RUNTIME: 'dotnet'
      WEBSITE_NODE_DEFAULT_VERSION: '~18'
      AzureWebJobsStorage: 'DefaultEndpointsProtocol=https;AccountName=${funcStorageAccountDeploy.name};AccountKey=${listKeys(funcStorageAccountDeploy.id, '2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
      WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: 'DefaultEndpointsProtocol=https;AccountName=${funcStorageAccountDeploy.name};AccountKey=${listKeys(funcStorageAccountDeploy.id, '2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
      WEBSITE_CONTENTSHARE: funcStorageAccountDeploy.name
    }
  }
}

// ** Outputs **
// *************

output applicationFunctionAppName string  = applicationFunctionAppName
