Param(
    [parameter(Mandatory = $false)]
    [string]$acrRegistryName = "ngAcrRegistry"
)

Write-Host "Retrieving ACR username" -ForegroundColor Cyan
$acrUserName = az acr credential show `
    --name $acrRegistryName `
    --query "username"

Write-Host "Retrieving ACR password" -ForegroundColor Cyan
$acrUserPassword = az acr credential show `
    --name $acrRegistryName `
    --query "passwords[0].value"

$regFullName = az acr show `
    --name $acrRegistryName `
    --query "loginServer"

Write-Host "Loggin in to ACR registry" -ForegroundColor Cyan
docker login  $regFullName `
    --username $acrUserName `
    --password $acrUserPassword

Write-Host "Succssfully logged in to ACR registry" -ForegroundColor Cyan
