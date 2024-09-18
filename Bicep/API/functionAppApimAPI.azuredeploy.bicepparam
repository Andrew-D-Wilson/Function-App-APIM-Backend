using './functionAppApimAPI.azuredeploy.bicep'

param functionAppName = 'ap1devfunc'
param apimInstanceName = 'myapidevapim'
param keyVaultName = 'ap1devkv'
param apiName = 'funcsAPI'
param apimAPIPath = '/appapi'
param apimAPIDisplayName = 'ApplicationAPI'
param apimAPIOperations = [
  {
    name: 'helloworldGet'
    displayName: 'Hello World GET'
    method: 'GET'
    path: '/HWGET'
    funcPath: '/HelloWorld'
    functionName: 'HelloWorld'
  }
  {
    name: 'helloworldPost'
    displayName: 'Hello World POST'
    method: 'POST'
    path: '/HWPOST'
    funcPath: '/HelloWorld'
    functionName: 'HelloWorld'
  }
]
