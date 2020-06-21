Param(
    [parameter(Mandatory = $false)]
    [string]$subscriptionName = "Microsoft Azure Sponsorship",
    [parameter(Mandatory = $false)]
    [string]$resourceGroupName = "akvResourceGroup",
    [parameter(Mandatory = $false)]
    [string]$resourceGroupLocaltion = "South East Asia",
    [parameter(Mandatory = $false)]
    [string]$akvName = "ngAkv"
)

# Set Azure subscription name
Write-Host "Setting Azure subscription to $subscriptionName"  -ForegroundColor Yellow
az account set --subscription=$subscriptionName

Create resource group name
Write-Host "Creating resource group $resourceGroupName in region $resourceGroupLocaltion" -ForegroundColor Yellow
az group create `
    --name=$resourceGroupName `
    --location=$resourceGroupLocaltion `
    --output=jsonc

# Create Azure Container Registry with Basic SKU and Admin user disabled
Write-Host "Creating Azure Key Vault $akvName under resource group $resourceGroupName " -ForegroundColor Yellow
az keyvault create `
    --name=$akvName `
    --resource-group=$resourceGroupName `
    --location=$resourceGroupLocaltion `
    --output=jsonc