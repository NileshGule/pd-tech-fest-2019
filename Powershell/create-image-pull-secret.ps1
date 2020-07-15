Param(
    [parameter(Mandatory = $false)]
    [string]$acrRegistryName = "ngacrregistry",
    [parameter(Mandatory = $false)]
    [string]$acrRegistryResourceGroup = "acrResourceGroup",
    [Parameter(Mandatory = $true)]
    [string]$ServicePrincipalID,
    [Parameter(Mandatory = $true)]
    [string]$SpPassword
)

#get login server name based on ACR registry name

$serverName = az acr show `
    --name $acrRegistryName `
    --resource-group $acrRegistryResourceGroup `
    --query loginServer

Write-Host "Creating docker secret" -ForegroundColor Yellow
kubectl create secret docker-registry acr-image-secret `
    --docker-server=$serverName `
    --docker-username=$ServicePrincipalID `
    --docker-password=$SpPassword

#verify secret was created
kubectl get secret acr-image-secret --output=yaml
