Param(
    [parameter(Mandatory = $false)]
    [string]$resourceGroupName = "demo-kedaSeriesRG",
    [parameter(Mandatory = $false)]
    [string]$clusterName = "aksmqCluster",
    [parameter(Mandatory = $false)]
    [string]$akvName = "ngAkv"
)

$msiClientID = az aks show `
    --resource-group $resourceGroupName `
    --name $clusterName `
    --query identityProfile.kubeletidentity.clientId `
    --output tsv

# set policy to access secrets in your Key Vault
az keyvault set-policy `
    --name $akvName `
    --secret-permissions get `
    --spn "53ecbf8b-166a-4c66-a553-dde574b96f50"

az vmss identity show `
    --resource-group MC_demo-kedaSeriesRG_aksmqCluster_southeastasia `
    -n aks-nodepool1-16332999-vmss `
    -o yaml
