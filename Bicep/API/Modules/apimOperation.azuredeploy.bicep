/**********************************
Bicep Template: API Operation Deploy
        Author: Andrew Wilson
***********************************/

targetScope = 'resourceGroup'

// ** User Defined Types **
// ************************

// TYPES: APIM API Operation
// - API Operation Definition
// - Query Parameter
// - Template Parameter
// - Header
// - Response

@export()
@description('APIM API Operation Definition')
@sealed()
type apiOperationDefinition = {
  @minLength(1)
  @maxLength(80)
  @description('The resource name')
  name: string
  @description('The backend function name')
  backendFunctionName: string
  @minLength(1)
  @maxLength(1000)
  @description('Relative URL rewrite template for the Function backend (in policy).')
  rewriteUrl: string
  @description('Properties of the Operation Contract')
  properties: {
    @minLength(1)
    @maxLength(300)
    @description('Operation Name.')
    displayName: string
    @description('A Valid HTTP Operation Method. Typical Http Methods like GET, PUT, POST but not limited by only them.')
    method: string
    @minLength(1)
    @maxLength(1000)
    @description('Relative URL template identifying the target resource for this operation. May include parameters. Example: /customers/{cid}/orders/{oid}/?date={date}')
    urlTemplate: string
    @maxLength(1000)
    @description('Description of the operation. May include HTML formatting tags.')
    description: string
    @description('Collection of URL template parameters.')
    templateParameters: templateParameter[]?
    @description('An entity containing request details.')
    request: {
      @description('Collection of operation request query parameters.')
      queryParameters: queryParameter[]?
      @description('Collection of operation request headers.')
      headers: header[]?
    }
    @description('Array of Operation responses.')
    responses: response[]?
  }
}

@export()
type queryParameter = {
  @description('Parameter name.')
  name: string
  @description('Parameter type.')
  type: string
  @description('Specifies whether parameter is required or not.')
  required: bool?
}

@export()
type templateParameter = {
  @description('Parameter name.')
  name: string
  @description('Parameter type.')
  type: string
  @description('Specifies whether parameter is required or not.')
  required: bool?
}

@export()
type header = {
  @description('Header name.')
  name: string
  @description('Header type.')
  type: string
  @description('Specifies whether header is required or not.')
  required: bool?
  @description('Header values.')
  values: string[]?
}

@export()
type response = {
  @description('Operation response HTTP status code.')
  statusCode: int
}

// ** Parameters **
// ****************

@description('API Management Service API Name Path')
param parentName string

@description('Definition of the operation to create')
param apiManagementApiOperationDefinition apiOperationDefinition

// ** Variables **
// ***************

// ** Resources **
// ***************

@description('Deploy function App API operation')
resource functionAppAPIGetOperation 'Microsoft.ApiManagement/service/apis/operations@2022-08-01' = {
  name: '${parentName}/${apiManagementApiOperationDefinition.name}'
  properties: apiManagementApiOperationDefinition.properties
}

// ** Outputs **
// *************
