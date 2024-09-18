/******************************************
Bicep Template: Application Secrets Deploy
        Author: Andrew Wilson
*******************************************/

targetScope = 'resourceGroup'

// ** Parameters **
// ****************

@description('Name of the Function App to add as a backend')
param applicationFunctionAppName string

@description('The name of the functions in the function app to add secrets for')
param functions string[]

@description('Name of the Key Vault to place secrets into')
param keyVaultName string

// ** Variables **
// ***************

// ** Resources **
// ***************

@description('Retrieve the existing Key Vault instance to store secrets')
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

@description('Vault the Functions sig as a secret - Deployment principle requires RBAC permissions to do this')
resource vaultFunctionsKey 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = [for function in functions: {
  name: '${applicationFunctionAppName}-${function}-key'
  parent: keyVault
  tags: {
    ResourceType: 'FunctionApp'
    ResourceName: '${applicationFunctionAppName}-${function}'
  }
  properties: {
    contentType: 'string'
    value: listKeys(resourceId('Microsoft.Web/sites/functions', applicationFunctionAppName, function),'2023-12-01').default
  }
}]

// ** Outputs **
// *************
