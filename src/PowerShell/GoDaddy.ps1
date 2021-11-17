param
(
	[string] $godaddy_domain,
	[string] $godaddy_name,
	[string] $godaddy_destination,
	[string] $godaddy_type,
	[string] $godaddy_key,
	[string] $godaddy_secret
)

#Authenication
$headers = @{}
$headers["Authorization"] = 'sso-key ' + $godaddy_key + ':' + $godaddy_secret

#Get the cname
Write-Host "Check GoDaddy.com for current CNAME details"
$CNameGetResponse = Invoke-WebRequest https://api.godaddy.com/v1/domains/$godaddy_domain/records/$godaddy_type/$godaddy_name -method get -headers $headers

#Set the cname
$results = ConvertFrom-Json -InputObject $CNameGetResponse.Content
if ($results.data.length -eq 0)
{
	[array] $request = @{data=$godaddy_destination; "port"=1; "priority"=0; "protocol"="none"; "service"="none"; "ttl"=3600; "weight"=1}
	$JSON = Convertto-Json $request

	$CNamePutResponse = Invoke-WebRequest https://api.godaddy.com/v1/domains/$godaddy_domain/records/$godaddy_type/$godaddy_name -method put -headers $headers -Body $json -ContentType "application/json"
	Write-Host "Updated cname record $godaddy_name in GoDaddy.com"
}
else
{
	Write-Host "No DNS update needed in GoDaddy.com"
}