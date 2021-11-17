param
(
	[string] $storageName,
	[string] $resourceGroupName,
	[string] $templatesLocation
)

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$timing = ""
$timing = -join($timing, "1. Deployment started: ", $stopwatch.Elapsed.TotalSeconds, "`n")
Write-Host "1. Deployment started: "$stopwatch.Elapsed.TotalSeconds
Write-Host "Parameters:"
Write-Host "storageName: $storageName"
Write-Host "resourceGroupName: $resourceGroupName"
Write-Host "templatesLocation: $templatesLocation"

#Variables
$storageAccountName = $storageName # "stgp$resourceGroupCode$environment$($resourceGroupLocation)".Replace("-","").ToLower() #Must be <= 24 lowercase letters and numbers.          
if ($storageAccountName.Length -gt 24)
{
    Write-Host "Storage account name must be 3-24 characters in length"
    Break
}
$timing = -join($timing, "2. Variables created: ", $stopwatch.Elapsed.TotalSeconds, "`n");
Write-Host "2. Variables created: "$stopwatch.Elapsed.TotalSeconds

#Resource group

#$timing = -join($timing, "3. Resource group created: ", $stopwatch.Elapsed.TotalSeconds, "`n");
#Write-Host "3. Resource group created: "$stopwatch.Elapsed.TotalSeconds

#storage
$storageOutput = az deployment group create --resource-group $resourceGroupName --name $storageAccountName --template-file "$templatesLocation/Storage.json" --parameters storageAccountName=$storageAccountName
$storageJSON = $storageOutput | ConvertFrom-Json
$storageAccountAccessKey = $storageJSON.properties.outputs.storageAccountKey.value
$env:STORAGEACCOUNTKEY = $storageAccountAccessKey
#$storageAccountNameKV = "StorageAccountKey$Environment"
#Write-Host "Setting value $storageAccountAccessKey for $storageAccountNameKV to key vault"
#az keyvault secret set --vault-name $dataKeyVaultName --name "$storageAccountNameKV" --value $storageAccountAccessKey #Upload the secret into the key vault
$timing = -join($timing, "5. Storage created: ", $stopwatch.Elapsed.TotalSeconds, "`n");
Write-Host "5. Storage created: "$stopwatch.Elapsed.TotalSeconds

Write-Host "storageAccountAccessKey: "$storageAccountAccessKey
$timing = -join($timing, "6. All Done: ", $stopwatch.Elapsed.TotalSeconds, "`n");
Write-Host "6. All Done: "$stopwatch.Elapsed.TotalSeconds
Write-Host "Timing: `n$timing"
Write-Host "Were there errors? (If the next line is blank, then no!) $error"