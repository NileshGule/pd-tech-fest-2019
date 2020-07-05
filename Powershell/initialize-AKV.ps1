Param(
    [parameter(Mandatory = $false)]
    [string]$subscriptionName = "Microsoft Azure Sponsorship",
    [parameter(Mandatory = $false)]
    [string]$resourceGroupName = "akvResourceGroup",
    [parameter(Mandatory = $false)]
    [string]$resourceGroupLocaltion = "South East Asia",
    [parameter(Mandatory = $false)]
    [string]$akvName = "ngAkv",
    [parameter(Mandatory = $false)]
    [string]$clusterName = "aksmqCluster",
    [parameter(Mandatory = $false)]
    [string]$aksResourceGroupName = "demo-kedaSeriesRG"
)

$subscriptionId = (az account show | ConvertFrom-Json).id
$tenantId = (az account show | ConvertFrom-Json).tenantId

# Set Azure subscription name
Write-Host "Setting Azure subscription to $subscriptionName"  -ForegroundColor Yellow
az account set --subscription=$subscriptionName

$akvRgExists = az group exists --name $resourceGroupName

if ($akvRgExists -eq $false) {
    Create resource group
    Write-Host "Creating resource group $resourceGroupName in region $resourceGroupLocaltion" -ForegroundColor Yellow
    az group create `
        --name=$resourceGroupName `
        --location=$resourceGroupLocaltion `
        --output=jsonc
}

$akv = az keyvault show --name $akvName --query name | ConvertFrom-Json
$keyVaultExists = $akv.Length -gt 0

if ($keyVaultExists -eq $false) {
    Create Azure Key Vault
    Write-Host "Creating Azure Key Vault $akvName under resource group $resourceGroupName " -ForegroundColor Yellow
    az keyvault create `
        --name=$akvName `
        --resource-group=$resourceGroupName `
        --location=$resourceGroupLocaltion `
        --output=jsonc
}
# retrieve existing AKS
Write-Host "Retrieving AKS details"
$aks = (az aks show `
        --name $clusterName `
        --resource-group $aksResourceGroupName | ConvertFrom-Json)

# Write-Host $aks

Write-Host "Retrieving the existing Azure Identity..."
$existingIdentity = (az resource list `
        -g $aks.nodeResourceGroup `
        --query "[?contains(name, 'aksmqCluster-agentpool')]")  | ConvertFrom-Json

$identity = az identity show `
    --name $existingIdentity.name `
    --resource-group $existingIdentity.resourceGroup | ConvertFrom-Json

Write-Host "Principal ID : $identity.principalId "
Write-Host "Client ID : $identity.clientId "

Write-Host "Setting policy to access secrets in Key Vault with Client Id..."
az keyvault set-policy `
    --name $akvName `
    --secret-permissions get `
    --spn $identity.clientId