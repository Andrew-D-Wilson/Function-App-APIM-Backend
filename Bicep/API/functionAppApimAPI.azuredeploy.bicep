/******************************************
Bicep Template: Function App APIM API
        Author: Andrew Wilson
*******************************************/

targetScope = 'resourceGroup'

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

var apimApiOperations = loadJsonContent('apimApiConfigurations/helloWorldApiOperationsConfiguration.json')

// Obtain single distinct list of functions used in operations 
var allFunction = map(apimApiOperations, op => op.backendFunctionName)
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
module functionAppAPIOperation 'Modules/apimOperation.azuredeploy.bicep' = [
  for operation in apimApiOperations: {
    name: '${operation.name}-deploy'
    params: {
      parentName: '${apimInstance.name}/${functionAppAPI.name}'
      apiManagementApiOperationDefinition: operation
    }
  }
]

@description('Retrieve the existing application Key Vault instance')
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

@description('Retrieve the existing function app func key secret')
resource vaultFunctionAppKey 'Microsoft.KeyVault/vaults/secrets@2023-07-01' existing = [
  for function in uniqueFunctions: {
    name: '${functionAppName}-${function}-key'
    parent: keyVault
  }
]

@description('Grant APIM Key Vault Reader for the function app API key secret')
resource grantAPIMPermissionsToSecret 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (function, index) in uniqueFunctions: {
    name: guid(keyVaultSecretsUserRoleDefinitionId, keyVault.id, function)
    scope: vaultFunctionAppKey[index]
    properties: {
      roleDefinitionId: subscriptionResourceId(
        'Microsoft.Authorization/roleDefinitions',
        keyVaultSecretsUserRoleDefinitionId
      )
      principalId: apimInstance.identity.principalId
      principalType: 'ServicePrincipal'
    }
  }
]

@description('Create the named values for the function app API keys')
resource functionAppBackendNamedValues 'Microsoft.ApiManagement/service/namedValues@2022-08-01' = [
  for (function, index) in uniqueFunctions: {
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
  }
]

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
module operationPolicy './Modules/apimOperationPolicy.azuredeploy.bicep' = [
  for (operation, index) in apimApiOperations: {
    name: 'operationPolicy-${operation.name}'
    params: {
      parentStructureForName: '${apimInstance.name}/${functionAppAPI.name}/${operation.name}'
      functionRelativePath: operation.rewriteUrl
      rawPolicy: apimOperationPolicyRaw
      key: '{{${apiName}-${operation.backendFunctionName}-key}}'
    }
    dependsOn: [
      functionAppAPIOperation
    ]
  }
]

// ** Outputs **
// *************
