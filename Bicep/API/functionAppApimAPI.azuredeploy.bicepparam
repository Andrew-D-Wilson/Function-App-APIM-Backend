using './functionAppApimAPI.azuredeploy.bicep'

param functionAppName = 'ap1devfunc'
param apimInstanceName = 'myapidevapim'
param keyVaultName = 'ap1devkv'
param apiName = 'funcsAPI'
param apimAPIPath = '/appapi'
param apimAPIDisplayName = 'ApplicationAPI'
