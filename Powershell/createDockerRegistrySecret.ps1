Param(
    [parameter(Mandatory = $false)]
    [string]$acrRegistryName = "ngAcrRegistry"
)

$acrUserPassword = az acr credential show --name $acrRegistryName --query "passwords[0].value"

$acrUserName = az acr credential show --name $acrRegistryName --query "username"

kubectl create secret docker-registry regcred `
    --docker-server=$acrRegistryName.azurecr.io `
    --docker-username=$acrUserName `
    --docker-password=$acrUserPassword

#verify secret was created
kubectl get secret regcred --output=yaml