/**********************************
Bicep Template: APIM Instance Deploy
        Author: Andrew Wilson
***********************************/

targetScope = 'resourceGroup'

// ** Parameters **
// ****************

@description('A prefix used to identify the api resources')
param apiPrefixName string

@description('The location that the resources will be deployed to - defaulting to the resource group location')
param location string = resourceGroup().location

@description('The environment that the resources are being deployed to')
@allowed([
  'dev'
  'test'
  'prod'
])
param env string = 'dev'

@description('The apim publisher email')
param apimPublisherEmail string

@description('The apim publisher name')
param apimPublisherName string

// ** Variables **
// ***************

var apimInstanceName = '${apiPrefixName}${env}apim'

// ** Resources **
// ***************

@description('Deployment of the APIM instance')
resource apimInstanceDeploy 'Microsoft.ApiManagement/service@2022-08-01' = {
  name: apimInstanceName
  location: location
  tags: {
    Environment: env
    Version: deployment().properties.template.contentVersion
  }
  sku: {
    capacity: 0
    name: 'Consumption'
  }
  properties: {
    publisherEmail: apimPublisherEmail
    publisherName: apimPublisherName
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// ** Outputs **
// *************

output apimInstanceName string = apimInstanceName
