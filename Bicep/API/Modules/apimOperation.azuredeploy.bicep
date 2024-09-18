/**********************************
Bicep Template: API Operation Deploy
        Author: Andrew Wilson
***********************************/

targetScope = 'resourceGroup'

// ** Parameters **
// ****************

@description('API Management Service API Name Path')
param parentName string

@description('Name of the API Operation')
param operationName string

@description('Display name for the API operation')
param operationDisplayName string

@description('API Operation Method e.g. GET')
param operationMethod string

@description('API Operation path that will be replaced with backend implementation through policy')
param operationPath string

// ** Variables **
// ***************

// ** Resources **
// ***************

@description('Deploy function App API operation')
resource functionAppAPIGetOperation 'Microsoft.ApiManagement/service/apis/operations@2022-08-01' = {
  name: '${parentName}/${operationName}'
  properties: {
    displayName: operationDisplayName
    method: operationMethod
    urlTemplate: operationPath
  }
}

// ** Outputs **
// *************
