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

#Create resource group
Write-Host "Creating resource group $resourceGroupName in region $resourceGroupLocaltion" -ForegroundColor Yellow
az group create `
    --name=$resourceGroupName `
    --location=$resourceGroupLocaltion `
    --output=jsonc

# Create Azure Key Vault
# Write-Host "Creating Azure Key Vault $akvName under resource group $resourceGroupName " -ForegroundColor Yellow
# az keyvault create `
#     --name=$akvName `
#     --resource-group=$resourceGroupName `
#     --location=$resourceGroupLocaltion `
#     --output=jsonc

# retrieve existing AKS
Write-Host "Retrieving AKS details"
$aks = (az aks show `
        --name $clusterName `
        --resource-group $aksResourceGroupName | ConvertFrom-Json)

Write-Host $aks

Write-Host "Creating Managed Identity Operator for Managed Identity"
az role assignment create `
    --role "Managed Identity Operator" `
    --assignee $aks.identityProfile.kubeletidentity.clientId `
    --scope /subscriptions/$subscriptionId/resourcegroups/$($aks.nodeResourceGroup)

Write-Host "Creating Virtual Machine Contributor Role for Managed Identity"
az role assignment create `
    --role "Virtual Machine Contributor" `
    --assignee $aks.identityProfile.kubeletidentity.clientId `
    --scope /subscriptions/$subscriptionId/resourcegroups/$($aks.nodeResourceGroup)

Write-Host "Retrieving the existing Azure Identity..."
$existingIdentity = (az resource list `
        -g $aks.nodeResourceGroup `
        --query "[?contains(name, 'aksmqCluster-agentpool')]")  | ConvertFrom-Json

$identity = az identity show `
    --name $existingIdentity.name `
    --resource-group $existingIdentity.resourceGroup | ConvertFrom-Json


$keyVault = az keyvault show --name $akvName | ConvertFrom-Json

Write-Host "Assigning Reader Role to new Identity for Key Vault..."
az role assignment create `
    --role "Reader" `
    --assignee $identity.principalId `
    --scope $keyVault.id

Write-Host "Setting policy to access secrets in Key Vault..."
az keyvault set-policy `
    --name $akvName `
    --secret-permissions get `
    --spn $identity.clientId

# az resource list `
#     -g MC_demo-kedaSeriesRG_aksmqCluster_southeastasia `
#     --query "[?contains(type, 'Microsoft.ManagedIdentity/userAssignedIdentities')]"

az resource list `
    -g MC_demo-kedaSeriesRG_aksmqCluster_southeastasia `
    --query "[?contains(name, 'aksmqCluster-agentpool')]"

kubectl create secret generic secrets-store-creds `
    --from-literal clientid="4bb98df3-4f04-4497-add6-871275a589e8"

az identity show `
    --name aksmqCluster-agentpool `
    --resource-group MC_demo-kedaSeriesRG_aksmqCluster_southeastasia

az aks show -g <resource group> -n <aks cluster name> --query identityProfile.kubeletidentity.clientId -o tsv