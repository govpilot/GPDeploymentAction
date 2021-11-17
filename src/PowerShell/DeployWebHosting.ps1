param
(
	[string] $hostingName,
	[string] $appinsightsName,
	[string] $resourceGroupName,
	[string] $hubResourceGroupName,
	#[string] $dataKeyVaultName,
	[string] $templatesLocation
)

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$timing = ""
$timing = -join($timing, "1. Deployment started: ", $stopwatch.Elapsed.TotalSeconds, "`n")
Write-Host "1. Deployment started: "$stopwatch.Elapsed.TotalSeconds
Write-Host "Parameters:"
Write-Host "resourceGroupName: $resourceGroupName"
#Write-Host "dataKeyVaultName: $dataKeyVaultName"
Write-Host "templatesLocation: $templatesLocation"
Write-Host "contactEmailAddress: $contactEmailAddress"

#Variables
$applicationInsightsName = $appinsightsName #"appi-gp$hubResourceGroupCode-$environment-$resourceGroupLocation"
$webhostingName = $hostingName #"plan-gp$resourceGroupCode-$environment-$resourceGroupLocation"
$CheckWhatIfs = $true
$timing = -join($timing, "2. Variables created: ", $stopwatch.Elapsed.TotalSeconds, "`n");
Write-Host "2. Variables created: "$stopwatch.Elapsed.TotalSeconds

#Application Insights
$applicationInsightsOutput = az deployment group create --resource-group $hubResourceGroupName --name $applicationInsightsName --template-file "$templatesLocation/ApplicationInsights.json" --parameters applicationInsightsName=$applicationInsightsName
$applicationInsightsJSON = $applicationInsightsOutput | ConvertFrom-Json
$applicationInsightsInstrumentationKey = $applicationInsightsJSON.properties.outputs.applicationInsightsInstrumentationKeyOutput.value
$env:APPINSIGHTS_KEY = $applicationInsightsInstrumentationKey
#$applicationInsightsInstrumentationKeyName = "ApplicationInsights--InstrumentationKey$Environment"
#Write-Host "Setting value $ApplicationInsightsInstrumentationKey for $applicationInsightsInstrumentationKeyName to key vault"
#az keyvault secret set --vault-name $dataKeyVaultName --name "$applicationInsightsInstrumentationKeyName" --value $ApplicationInsightsInstrumentationKey #Upload the secret into the key vault
$timing = -join($timing, "10. Application created: ", $stopwatch.Elapsed.TotalSeconds, "`n");
Write-Host "10. Application insights created: "$stopwatch.Elapsed.TotalSeconds

#Web hosting
az deployment group create --resource-group $resourceGroupName --name $webhostingName --template-file "$templatesLocation/WebHosting.json" --parameters hostingPlanName=$webhostingName 
$timing = -join($timing, "11. Web hosting created: ", $stopwatch.Elapsed.TotalSeconds, "`n");
Write-Host "11. Web hosting created: "$stopwatch.Elapsed.TotalSeconds

Write-Host "applicationInsightsInstrumentationKey: "$applicationInsightsInstrumentationKey
$timing = -join($timing, "15. All Done: ", $stopwatch.Elapsed.TotalSeconds, "`n");
Write-Host "15. All Done: "$stopwatch.Elapsed.TotalSeconds
Write-Host "Timing: `n$timing"
Write-Host "Were there errors? (If the next line is blank, then no!) $error"