/******************************************************
Bicep Template: Application Security Config (Easy Auth)
        Author: Andrew Wilson
*******************************************************/

targetScope = 'resourceGroup'

// ** User Defined Types **
// ************************

// ** Parameters **
// ****************

@description('Name of the Function App to Retrieve')
param applicationFunctionAppName string

@description('Name of the APIM instance')
param apimInstanceName string

@description('Function App Easy Auth Client Id')
param functionAppEasyAuthClientId string

// ** Variables **
// ***************

// ** Resources **
// ***************

@description('Retrieve Existing Function App')
resource applicationFunctionAppDeploy 'Microsoft.Web/sites@2023-12-01' existing = {
  name: applicationFunctionAppName
}

@description('Retrieve the existing APIM Instance')
resource apimInstance 'Microsoft.ApiManagement/service@2022-08-01' existing = {
  name: apimInstanceName
}

@description('Setup the Easy Auth config settings for the Function App')
resource applicationAuthSettings 'Microsoft.Web/sites/config@2023-12-01' = {
  name: 'authsettingsV2'
  parent: applicationFunctionAppDeploy
  properties: {
    globalValidation: {
      requireAuthentication: true
      unauthenticatedClientAction: 'Return401'
    }
    httpSettings: {
      requireHttps: true
      routes: {
        apiPrefix: '/.auth'
      }
      forwardProxy: {
        convention: 'NoProxy'
      }
    }
    identityProviders: {
      azureActiveDirectory: {
        enabled: true
        registration: {
          openIdIssuer: uri('https://sts.windows.net/', tenant().tenantId)
          clientId: functionAppEasyAuthClientId
          clientSecretSettingName: 'MICROSOFT_PROVIDER_AUTHENTICATION_SECRET'
        }
        validation: {
          allowedAudiences: environment().authentication.audiences
          defaultAuthorizationPolicy: {
            allowedPrincipals: {
              identities: [
                apimInstance.identity.principalId
              ]
            }
          }
        }
      }
    }
    platform: {
      enabled: true
      runtimeVersion: '~1'
    }
  }
}

// ** Outputs **
// *************
