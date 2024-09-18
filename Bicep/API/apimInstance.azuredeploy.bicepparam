using './apimInstance.azuredeploy.bicep'

param apiPrefixName = 'myapi'
param location = '[resourceGroup().location]'
param env = 'dev'
param apimPublisherEmail = ''
param apimPublisherName = ''
