using './applicationSecrets.azuredeploy.bicep'

param applicationFunctionAppName = 'ap1devfunc'
param functions = ['HelloWorld']
param keyVaultName = 'ap1devkv'
