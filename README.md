# Function App APIM Backend

[![GitHub Issues][badge_issues]][link_issues]
[![GitHub Stars][badge_repo_stars]][link_repo]
[![Repo Language][badge_language]][link_repo]
[![Repo License][badge_license]][link_repo]

[badge_issues]: https://img.shields.io/github/issues/Andrew-D-Wilson/Function-App-APIM-Backend?style=for-the-badge
[link_issues]: https://github.com/Andrew-D-Wilson/Function-App-APIM-Backend/issues
[badge_repo_stars]: https://img.shields.io/github/stars/Andrew-D-Wilson/Function-App-APIM-Backend?logo=github&style=for-the-badge
[badge_language]: https://img.shields.io/badge/language-Bicep/CSharp-blue?style=for-the-badge
[badge_license]: https://img.shields.io/github/license/Andrew-D-Wilson/Function-App-APIM-Backend?style=for-the-badge
[link_repo]: https://github.com/Andrew-D-Wilson/Function-App-APIM-Backend

This repository contains configurable and secure methods in setting up the front-to-backend routing in APIM for Azure Function Apps.
1. Using Function Key and Bicep Configuration
   - See Blog Post for more details: [Azure API Management | Function App Backend](https://andrewilson.co.uk/post/2024/10/function-app-apim-backend/)
2. Using Function App Easy Auth and Configuration through Bicep
   - See Blog Post for more details: [Easy Auth | Function App with Azure API Management](https://andrewilson.co.uk/post/2024/11/function-app-easy-auth-apim/)
## Getting started
### 1: Function Key and Bicep Configuration.

1. Application Deployment
   1. Deploy the Application Services into Azure
      1. Update the [Application Bicep Parameters from their defaults](https://github.com/Andrew-D-Wilson/Function-App-APIM-Backend/blob/main/Bicep/Application/application.azuredeploy.bicepparam)
      2. Build both the [Bicep Template](https://github.com/Andrew-D-Wilson/Function-App-APIM-Backend/blob/main/Bicep/Application/application.azuredeploy.bicep) and [Bicep Parameter File](https://github.com/Andrew-D-Wilson/Function-App-APIM-Backend/blob/main/Bicep/Application/application.azuredeploy.bicepparam).
      3. Deploy the Application Template to Azure.
   2. Deploy the demo [Function](https://github.com/Andrew-D-Wilson/Function-App-APIM-Backend/tree/main/Application) to the Function App you deployed into Azure in step 1.
   3. Deploy Application Secrets to KeyVault
      1.  Update the [Application Secrets Bicep Parameters from their defaults](https://github.com/Andrew-D-Wilson/Function-App-APIM-Backend/blob/main/Bicep/Application/applicationSecrets.azuredeploy.bicepparam)
      2. Build both the [Bicep Template](https://github.com/Andrew-D-Wilson/Function-App-APIM-Backend/blob/main/Bicep/Application/applicationSecrets.azuredeploy.bicep) and [Bicep Parameter File](https://github.com/Andrew-D-Wilson/Function-App-APIM-Backend/blob/main/Bicep/Application/applicationSecrets.azuredeploy.bicepparam).
      3. Deploy the Application Secrets Template to Azure.
2. APIM and API Deployment
   1. Deploy an APIM Instance into Azure
      1. Update the [APIM Instance Bicep Parameters from their defaults](https://github.com/Andrew-D-Wilson/Function-App-APIM-Backend/blob/main/Bicep/API/apimInstance.azuredeploy.bicepparam)
      2. Build both the [Bicep Template](https://github.com/Andrew-D-Wilson/Function-App-APIM-Backend/blob/main/Bicep/API/apimInstance.azuredeploy.bicep) and [Bicep Parameter File](https://github.com/Andrew-D-Wilson/Function-App-APIM-Backend/blob/main/Bicep/API/apimInstance.azuredeploy.bicepparam).
      3. Deploy the APIM Instance Template to Azure.
   2. Deploy the APIM API with the recently deployed Function as the Backend.
      1. Update the [Function App APIM API Bicep Parameters from their defaults](https://github.com/Andrew-D-Wilson/Function-App-APIM-Backend/blob/main/Bicep/API/functionAppApimAPI.azuredeploy.bicepparam) and make sure these changes line up in the API operations configuration [config file](https://github.com/Andrew-D-Wilson/Function-App-APIM-Backend/blob/main/Bicep/API/apimApiConfigurations/helloWorldApiOperationsConfiguration.json)
      2. Build both the [Bicep Template](https://github.com/Andrew-D-Wilson/Function-App-APIM-Backend/blob/main/Bicep/API/functionAppApimAPI.azuredeploy.bicep) and [Bicep Parameter File](https://github.com/Andrew-D-Wilson/Function-App-APIM-Backend/blob/main/Bicep/API/functionAppApimAPI.azuredeploy.bicepparam).
      3. Deploy the Function App APIM API Template to Azure.

You will now be in a position to call your APIM API which will be using the Function App as its backend.

** This example also demonstrates having multiple APIM Operations pointing to the same Azure Function exposing multiple Method Operations i.e. GET | POST etc.

### 2: Using Function App Easy Auth and Configuration through Bicep.
1. Application Deployment
   1. Configure the Function App to Use [Microsoft Entra sign-in](https://learn.microsoft.com/en-us/azure/app-service/configure-authentication-provider-aad?tabs=workforce-configuration).
   2. Deploy the Application Services into Azure
      1. Update the [Application Bicep Parameters from their defaults](https://github.com/Andrew-D-Wilson/Function-App-APIM-Backend/blob/main/Bicep/Application/applicationEasyAuth.azuredeploy.bicepparam)
      2. Build both the [Bicep Template](https://github.com/Andrew-D-Wilson/Function-App-APIM-Backend/blob/main/Bicep/Application/applicationEasyAuth.azuredeploy.bicep) and [Bicep Parameter File](https://github.com/Andrew-D-Wilson/Function-App-APIM-Backend/blob/main/Bicep/Application/applicationEasyAuth.azuredeploy.bicepparam).
      3. Deploy the Application Template to Azure.
   3. Deploy the demo [Function](https://github.com/Andrew-D-Wilson/Function-App-APIM-Backend/tree/main/Application) to the Function App you deployed into Azure in step 1 but setting AuthorizationLevel to Anonymous.
3. APIM and API Deployment
   1. Deploy an APIM Instance into Azure
      1. Update the [APIM Instance Bicep Parameters from their defaults](https://github.com/Andrew-D-Wilson/Function-App-APIM-Backend/blob/main/Bicep/API/apimInstance.azuredeploy.bicepparam)
      2. Build both the [Bicep Template](https://github.com/Andrew-D-Wilson/Function-App-APIM-Backend/blob/main/Bicep/API/apimInstance.azuredeploy.bicep) and [Bicep Parameter File](https://github.com/Andrew-D-Wilson/Function-App-APIM-Backend/blob/main/Bicep/API/apimInstance.azuredeploy.bicepparam).
      3. Deploy the APIM Instance Template to Azure.
   2. Deploy the APIM API with the recently deployed Function as the Backend.
      1. Update the [Function App APIM API Bicep Parameters from their defaults](https://github.com/Andrew-D-Wilson/Function-App-APIM-Backend/blob/main/Bicep/API/functionAppApimAPIEasyAuth.azuredeploy.bicepparam) and make sure these changes line up in the API operations configuration [config file](https://github.com/Andrew-D-Wilson/Function-App-APIM-Backend/blob/main/Bicep/API/apimApiConfigurations/helloWorldApiOperationsConfiguration.json)
      2. Build both the [Bicep Template](https://github.com/Andrew-D-Wilson/Function-App-APIM-Backend/blob/main/Bicep/API/functionAppApimAPIEasyAuth.azuredeploy.bicep) and [Bicep Parameter File](https://github.com/Andrew-D-Wilson/Function-App-APIM-Backend/blob/main/Bicep/API/functionAppApimAPIEasyAuth.azuredeploy.bicepparam).
      3. Deploy the Function App APIM API Template to Azure.

You will now be in a position to call your APIM API which will be using the Function App as its backend.

** This example also demonstrates having multiple APIM Operations pointing to the same Azure Function exposing multiple Method Operations i.e. GET | POST etc.
## Author
👤 Andrew Wilson

[![Website][badge_blog]][link_blog]
[![LinkedIn][badge_linkedin]][link_linkedin]

[![Twitter][badge_twitter]][link_twitter]
[![BlueSky][badge_bluesky]][link_bluesky]


## License
The Function App APIM Backend is made available under the terms and conditions of the [MIT license](LICENSE).

[badge_blog]: https://img.shields.io/badge/blog-andrewilson.co.uk-blue?style=for-the-badge
[link_blog]: https://andrewilson.co.uk/

[badge_linkedin]: https://img.shields.io/badge/LinkedIn-Andrew%20Wilson-blue?style=for-the-badge&logo=linkedin
[link_linkedin]: https://www.linkedin.com/in/andrew-wilson-792345106

[badge_twitter]: https://img.shields.io/badge/follow-%40Andrew__DWilson-blue?logo=twitter&style=for-the-badge&logoColor=white
[link_twitter]: https://twitter.com/Andrew_DWilson

[badge_bluesky]: https://img.shields.io/badge/Bluesky-%40andrewilson.co.uk-blue?logo=bluesky&style=for-the-badge&logoColor=white
[link_bluesky]: https://bsky.app/profile/andrewilson.co.uk
