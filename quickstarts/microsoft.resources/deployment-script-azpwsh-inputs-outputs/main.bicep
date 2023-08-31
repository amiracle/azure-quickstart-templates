@description('An example of a boolean parameter')
param myBool bool

@description('An example of an integer parameter')
param myInt int

@description('An example of a string parameter')
param myString string

@description('An example of an array parameter')
param myArray array

@description('An example of an object parameter')
param myObject object

var scriptArguments = {
  myBool: myBool ? '$True' : '$False'
  myInt: '${myInt}'
  myString: '\'${replace(myString, '\'', '\\\'')}\''
  myArray: '(ConvertFrom-Json \'${replace(replace(string(myArray), '\'', '\\\''), '"', '\\"')}\')'
  myObject: '(ConvertFrom-Json \'${replace(replace(string(myObject), '\'', '\\\''), '"', '\\"')}\')'
}
var scriptContent = loadTextContent('./script.ps1')

resource myScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'myScript'
#disable-next-line no-loc-expr-outside-params
  location: resourceGroup().location
  kind: 'AzurePowerShell'
  properties: {
    azPowerShellVersion: '10.1'
    retentionInterval: 'PT1H'
    scriptContent: scriptContent
    arguments: join(map(items(scriptArguments), arg => '-${arg.key} ${arg.value}'), ' ')
  }
}

resource logs 'Microsoft.Resources/deploymentScripts/logs@2020-10-01' existing = {
  parent: myScript
  name: 'default'
}

@description('The logs written by the script')
output logs array = split(logs.properties.log, '\n')

@description('The output returned by the script')
output outputs object = myScript.properties.outputs
