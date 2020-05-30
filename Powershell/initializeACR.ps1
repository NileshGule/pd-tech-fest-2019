Param(
    [parameter(Mandatory = $false)]
    [string]$subscriptionName = "Microsoft Azure Sponsorship",
    [parameter(Mandatory = $false)]
    [string]$resourceGroupName = "acrResourceGroup",
    [parameter(Mandatory = $false)]
    [string]$resourceGroupLocaltion = "South East Asia",
    [parameter(Mandatory = $false)]
    [string]$acrRegistryName = "ngAcrRegistry"
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
Write-Host "Creating Azure Container Registry $acrRegistryName under resource group $resourceGroupName " -ForegroundColor Yellow
az acr create `
    --name=$acrRegistryName `
    --resource-group=$resourceGroupName `
    --sku=Basic `
    --admin-enabled=false `
    --output=jsonc

#If ACR registry is created without admin user, it can be updated usign the command
# az acr update -n ngAcrRegistry --admin-enabled true