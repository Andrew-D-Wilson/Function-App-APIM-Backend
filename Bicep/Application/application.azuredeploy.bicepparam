using './application.azuredeploy.bicep'

param applicationPrefixName = 'ap1'
param applicationName = 'Application1'
param env = 'dev'
param location = '[resourceGroup().location]'
