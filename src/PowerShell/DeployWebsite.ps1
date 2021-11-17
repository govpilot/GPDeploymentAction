param
(
	[string] $appName,
	[string] $hostingName,
	[string] $storageName,
	[string] $resourceGroupName,
	[string] $templatesLocation
)

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$timing = ""
$timing = -join($timing, "1. Deployment started: ", $stopwatch.Elapsed.TotalSeconds, "`n")
Write-Host "1. Deployment started: "$stopwatch.Elapsed.TotalSeconds
Write-Host "Parameters:"
Write-Host "appName: $appName"
Write-Host "hostingName: $hostingName"
Write-Host "storageName: $storageName"
Write-Host "resourceGroupName: $resourceGroupName"
Write-Host "templatesLocation: $templatesLocation"

#Variables
$webSiteName = $appName #"app-gp$resourceGroupCode-$appPrefix-$environment-$resourceGroupLocation"
$webhostingName = $hostingName #"plan-gp$resourceGroupCode-$environment-$resourceGroupLocation"
$storageAccountName = $storageName #"stgp$resourceGroupCode$environment$($resourceGroupLocation)".Replace("-","").ToLower() #Must be <= 24 lowercase letters and numbers.
if ($storageAccountName.Length -gt 24)
{
    Write-Host "Storage account name must be 3-24 characters in length"
    Break
}

$timing = -join($timing, "2. Variables created: ", $stopwatch.Elapsed.TotalSeconds, "`n");
Write-Host "2. Variables created: "$stopwatch.Elapsed.TotalSeconds

#Web site
az deployment group create --resource-group $resourceGroupName --name $webSiteName --template-file "$templatesLocation/Website.json" --parameters webSiteName=$webSiteName hostingPlanName=$webhostingName storageAccountName=$storageAccountName
    
#Setup web site managed identity and setting keyvault access permissions
$websiteProdSlotIdentity = az webapp identity assign --resource-group $resourceGroupName --name $webSiteName 
$websiteStagingSlotIdentity = az webapp identity assign --resource-group $resourceGroupName --name $webSiteName --slot staging
#$websiteProdSlotIdentityPrincipalId = ($websiteProdSlotIdentity | ConvertFrom-Json | SELECT PrincipalId).PrincipalId
#$websiteStagingSlotIdentityPrincipalId =($websiteStagingSlotIdentity | ConvertFrom-Json | SELECT PrincipalId).PrincipalId
Write-Host "Prod PrincipalId: " $websiteProdSlotIdentityPrincipalId
Write-Host "Staging PrincipalId: " $websiteStagingSlotIdentityPrincipalId
#Write-Host "Started access policy 1 for key vault"
#$policy1 = az keyvault set-policy --name $dataKeyVaultName --object-id $websiteProdSlotIdentityPrincipalId --secret-permissions list get
#Write-Host "Finished access policy 1 for key vault"
#Write-Host "Started access policy 2 for key vault"
#$policy2 = az keyvault set-policy --name $dataKeyVaultName --object-id $websiteStagingSlotIdentityPrincipalId --secret-permissions list get
#Write-Host "Finished access policy 2 for key vault"

#Get application insights from key vault
#$applicationInsightsName = "ApplicationInsights--InstrumentationKey$environment"
#Write-Host "Getting value application insights $applicationInsightsName secret from key vault"
#$applicationInsightsJson = az keyvault secret show --vault-name $dataKeyVaultName --name $applicationInsightsName 
$applicationInsightsKey = $env:APPINSIGHTS_KEY#($applicationInsightsJson | ConvertFrom-Json).value
#Set secrets into appsettings 
Write-Host "Setting appsettings $webSiteName connectionString: $applicationInsightsKey"
az webapp config appsettings set --resource-group $resourceGroupName --name $webSiteName --slot staging --settings "APPINSIGHTS_INSTRUMENTATIONKEY=$applicationInsightsKey" 


##Generate the certificate
#$newCert = az webapp config ssl create --hostname $websiteDomainName --name $webSiteName --resource-group $resourceGroupName --only-show-errors
#$thumbprint = ($newCert | ConvertFrom-Json).thumbprint
#Write-Host "Thumbprint id: $thumbprint"
#Write-Host "Cmd: az webapp config ssl create --hostname $websiteDomainName --name $webSiteName --resource-group $resourceGroupName"
#Write-Host $newCert
##Bind the certificate to the web app
#az webapp config ssl bind --certificate-thumbprint $thumbprint --ssl-type SNI --name $webSiteName --resource-group $resourceGroupName

$timing = -join($timing, "13. Website created: ", $stopwatch.Elapsed.TotalSeconds, "`n");
Write-Host "13. Website created: "$stopwatch.Elapsed.TotalSeconds

$timing = -join($timing, "15. All Done: ", $stopwatch.Elapsed.TotalSeconds, "`n");
Write-Host "15. All Done: "$stopwatch.Elapsed.TotalSeconds
Write-Host "Timing: `n$timing"
Write-Host "Were there errors? (If the next line is blank, then no!) $error"