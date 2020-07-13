Param(
    [parameter(Mandatory = $false)]
    [string]$acrRegistryName = "ngAcrRegistry",
    [Parameter(Mandatory = $true)]
    [string]$ServicePrincipalID,
    [Parameter(Mandatory = $true)]
    [string]$SpPassword
)

kubectl create secret docker-registry acr-image-secret `
    --docker-server=$acrRegistryName.azurecr.io `
    --docker-username=$ServicePrincipalID `
    --docker-password=$SpPassword

#verify secret was created
kubectl get secret acr-image-secret --output=yaml