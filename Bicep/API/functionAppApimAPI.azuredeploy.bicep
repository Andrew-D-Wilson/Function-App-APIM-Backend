/******************************************
Bicep Template: Function App APIM API
        Author: Andrew Wilson
*******************************************/

targetScope = 'resourceGroup'

// ** User Defined Types **
// ************************

@description('Configuration properties for setting up Function App APIM API Operations')
@metadata({
  name: 'Name of the API Operation'
  displayName: 'User friendly name of the API Operation'
  method: 'The API Operations HTTP method'
  path: 'APIM API Operation path that will be replaced with backend implementation through policy. Relative Paths included and matching Function App.'
  funcPath: 'Function App relative path to the function'
  functionName: 'Name of the Function to use for the Operation Backend'
})
@sealed()
type apimAPIOperation = {
  name: string
  displayName: string
  method: 'GET' | 'PUT' | 'POST' | 'PATCH' | 'DELETE'
  path: string
  funcPath: string
  functionName: string
}

@description('One or more APIM API Operations to configure')
@minLength(1)
type apimAPIOperationArray = apimAPIOperation[]

// ** Parameters **
// ****************

@description('Name of the Function App to add as a backend')
param functionAppName string

@description('Name of the APIM instance')
param apimInstanceName string

@description('Name of the Key Vault instance')
param keyVaultName string

@description('Name of the API to create in APIM')
param apiName string

@description('APIM API path')
param apimAPIPath string

@description('APIM API display name')
param apimAPIDisplayName string

@description('Array of API operations')
param apimAPIOperations apimAPIOperationArray

// ** Variables **
// ***************

// Function App Base URL
var funcBaseUrl = 'https://${functionApp.properties.defaultHostName}/api'

// Key Vault Read Access
var keyVaultSecretsUserRoleDefinitionId = '4633458b-17de-408a-b874-0445c86b69e6'

// All Operations Policy
var apimAPIPolicyRaw = loadTextContent('./APIM-Policies/APIMAllOperationsPolicy.xml')
var apimAPIPolicy = replace(apimAPIPolicyRaw, '__apiName__', apiName)

// Operation Policy Template
var apimOperationPolicyRaw = loadTextContent('./APIM-Policies/APIMOperationPolicy.xml')

// Obtain single distinct list of functions used in operations 
var allFunction = map(apimAPIOperations, op => op.functionName)
var uniqueFunctions = union(allFunction, allFunction)

// ** Resources **
// ***************

@description('Retrieve the existing APIM Instance, will add APIs and Policies to this resource')
resource apimInstance 'Microsoft.ApiManagement/service@2022-08-01' existing = {
  name: apimInstanceName
}

@description('Create the Function App API in APIM')
resource functionAppAPI 'Microsoft.ApiManagement/service/apis@2022-08-01' = {
  name: apiName
  parent: apimInstance
  properties: {
    displayName: apimAPIDisplayName
    subscriptionRequired: true
    path: apimAPIPath
    protocols: [
      'https'
    ]
  }
}

@description('Retrieve the existing Function App for linking as a backend')
resource functionApp 'Microsoft.Web/sites@2022-09-01' existing = {
  name: functionAppName
}

@description('Deploy function App API operations')
module functionAppAPIOperation 'Modules/apimOperation.azuredeploy.bicep' = [for operation in apimAPIOperations: {
  name: '${operation.name}-deploy'
  params: {
    parentName: '${apimInstance.name}/${functionAppAPI.name}'
    operationDisplayName: operation.displayName
    operationMethod: operation.method
    operationPath: operation.path
    operationName: operation.name
  }
}]

@description('Retrieve the existing application Key Vault instance')
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

@description('Retrieve the existing function app func key secret')
resource vaultFunctionAppKey 'Microsoft.KeyVault/vaults/secrets@2023-07-01' existing = [for function in uniqueFunctions : {
  name: '${functionAppName}-${function}-key'
  parent: keyVault
}]

@description('Grant APIM Key Vault Reader for the function app API key secret')
resource grantAPIMPermissionsToSecret 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (function, index) in uniqueFunctions: {
  name: guid(keyVaultSecretsUserRoleDefinitionId, keyVault.id, function)
  scope: vaultFunctionAppKey[index]
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', keyVaultSecretsUserRoleDefinitionId)
    principalId: apimInstance.identity.principalId
    principalType: 'ServicePrincipal'
  }
}]

@description('Create the named values for the function app API keys')
resource functionAppBackendNamedValues 'Microsoft.ApiManagement/service/namedValues@2022-08-01' = [for (function, index) in uniqueFunctions: {
  name: '${apiName}-${function}-key'
  parent: apimInstance
  properties: {
    displayName: '${apiName}-${function}-key'
    tags: [
      'key'
      'functionApp'
      '${apiName}'
      '${function}'
    ]
    secret: true
    keyVault: {
      identityClientId: null
      secretIdentifier: '${keyVault.properties.vaultUri}secrets/${vaultFunctionAppKey[index].name}'
    }
  }
  dependsOn: [
    grantAPIMPermissionsToSecret
  ]
}]

@description('Create the backend for the Function App API')
resource functionAppBackend 'Microsoft.ApiManagement/service/backends@2022-08-01' = {
  name: apiName
  parent: apimInstance
  properties: {
    protocol: 'http'
    url: funcBaseUrl
    resourceId: uri(environment().resourceManager, functionApp.id)
    tls: {
      validateCertificateChain: true
      validateCertificateName: true
    }
  }
}

@description('Create a policy for the function App API and all its operations - linking the function app backend')
resource functionAppAPIAllOperationsPolicy 'Microsoft.ApiManagement/service/apis/policies@2022-08-01' = {
  name: 'policy'
  parent: functionAppAPI
  properties: {
    value: apimAPIPolicy
    format: 'xml'
  }
  dependsOn: [
    functionAppBackend
  ]
}

@description('Add query strings via policy')
module operationPolicy './Modules/apimOperationPolicy.azuredeploy.bicep' = [for (operation, index) in apimAPIOperations: {
  name: 'operationPolicy-${operation.name}'
  params: {
    parentStructureForName: '${apimInstance.name}/${functionAppAPI.name}/${operation.name}'
    functionRelativePath: operation.funcPath
    rawPolicy: apimOperationPolicyRaw
    key: '{{${apiName}-${operation.functionName}-key}}'
  }
  dependsOn: [
    functionAppAPIOperation
  ]
}]

// ** Outputs **
// *************
