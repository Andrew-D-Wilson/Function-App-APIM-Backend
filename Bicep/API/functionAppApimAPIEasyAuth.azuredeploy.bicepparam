using './functionAppApimAPIEasyAuth.azuredeploy.bicep'

param functionAppName = 'ap1devfunc'
param apimInstanceName = 'myapidevapim'
param apiName = 'funcsAPI'
param apimAPIPath = '/appapi'
param apimAPIDisplayName = 'ApplicationAPI'
param functionAppEasyAuthClientId = ''
