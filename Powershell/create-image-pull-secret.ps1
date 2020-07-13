Param(
    [parameter(Mandatory = $false)]
    [string]$acrRegistryName = "ngAcrRegistry"
)

$spName = "kedasp"

$password = az ad sp credential reset `
    --name http://$spName `
    --query password `
    --output tsv

kubectl create secret docker-registry regcred `
    --docker-server=$acrRegistryName.azurecr.io `
    --docker-username=$spName `
    --docker-password=$password

#verify secret was created
kubectl get secret regcred --output=yaml