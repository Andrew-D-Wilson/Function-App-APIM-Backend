/****************************************************
Bicep Template: Function App APIM API With Easy Auth
        Author: Andrew Wilson
****************************************************/

targetScope = 'resourceGroup'

// ** Parameters **
// ****************

@description('Name of the Function App to add as a backend')
param functionAppName string

@description('Name of the APIM instance')
param apimInstanceName string

@description('Name of the API to create in APIM')
param apiName string

@description('APIM API path')
param apimAPIPath string

@description('APIM API display name')
param apimAPIDisplayName string

@description('Function App Easy Auth Client Id')
param functionAppEasyAuthClientId string

// ** Variables **
// ***************

// Function App Base URL
var funcBaseUrl = 'https://${functionApp.properties.defaultHostName}/api'

// All Operations Policy
var apimAPIPolicyRaw = loadTextContent('./APIM-Policies/EasyAuth/APIMAllOperationsPolicy.xml')
var apimAPIPolicy = replace(apimAPIPolicyRaw, '__apiName__', apiName)

// Operation Policy Template
var apimOperationPolicyRaw = loadTextContent('./APIM-Policies/EasyAuth/APIMOperationPolicy.xml')

var apimApiOperations = loadJsonContent('apimApiConfigurations/helloWorldApiOperationsConfiguration.json')

// APIM Managed Identity Authentication Policy Fragment Template
var apimMIAuthFragPolicy = loadTextContent('./APIM-Policies/EasyAuth/APIMManagedIdentityAuthentication.PolicyFragment.xml')

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

@description('Apply AuthSettingsV2 Easy Auth for Function App')
module functionAppEasyAuthConfig 'Modules/applicationSecurityConfig.azuredeploy.bicep' = {
  name: 'functionAppEasyAuthConfig'
  params: {
    apimInstanceName: apimInstance.name
    applicationFunctionAppName: functionApp.name
    functionAppEasyAuthClientId: functionAppEasyAuthClientId
  }
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

@description('APIM System Assigned Managed Identity Authentication Policy Fragment')
resource apimMIAuthPolicyFragment 'Microsoft.ApiManagement/service/policyFragments@2022-08-01' = {
  name: 'MIAuthFrag'
  parent: apimInstance
  properties: {
    value: apimMIAuthFragPolicy
    description: 'APIM System Assigned Managed Identity Authentication Policy Fragment'
    format: 'xml'
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
    apimMIAuthPolicyFragment
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
