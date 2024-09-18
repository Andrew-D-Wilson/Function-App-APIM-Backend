/********************************************
Bicep Template: APIM FUNC API Operation Policy
        Author: Andrew Wilson
********************************************/

targetScope = 'resourceGroup'

// ** Parameters **
// ****************

@description('The Parent naming structure for the Policy')
param parentStructureForName string

@description('The function relative path')
param functionRelativePath string

@description('The raw policy document template')
param rawPolicy string

@description('The named value name for the workflow key')
param key string = ''

// ** Variables **
// ***************

var policyURI = replace(rawPolicy, '__uri__', functionRelativePath)
var policyKEY = replace(policyURI, '__key__', key)

// ** Resources **
// ***************

@description('Add query strings via policy')
resource operationPolicy 'Microsoft.ApiManagement/service/apis/operations/policies@2022-08-01' = {
  name: '${parentStructureForName}/policy'
  properties: {
    value: policyKEY
    format: 'xml'
  }
}

// ** Outputs **
// *************
