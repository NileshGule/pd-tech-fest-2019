Param(
    [parameter(Mandatory = $false)]
    [string]$subscriptionName = "Microsoft Azure Sponsorship",
    [parameter(Mandatory = $false)]
    [string]$resourceGroupName = "azure-container-app-rg",
    [parameter(Mandatory = $false)]
    [string]$resourceGroupLocaltion = "eastasia",
    [parameter(Mandatory = $false)]
    [string]$environmentName = "aci-dev-env"
)

# Set Azure subscription name
Write-Host "Setting Azure subscription to $subscriptionName"  -ForegroundColor Yellow
az account set --subscription=$subscriptionName

$aksRgExists = az group exists --name $resourceGroupName

Write-Host "$resourceGroupName exists : $aksRgExists"

if ($aksRgExists -eq $false) {

    # Create resource group name
    Write-Host "Creating resource group $resourceGroupName in region $resourceGroupLocaltion" -ForegroundColor Yellow
    az group create `
        --name=$resourceGroupName `
        --location=$resourceGroupLocaltion `
        --output=jsonc
}

# Create Azure Container App environment
Write-Host "Creating Azure Container App environment named : $environmentName "  -ForegroundColor Yellow

az containerapp env create `
    --name $environmentName `
    --resource-group $resourceGroupName `
    --location $resourceGroupLocaltion

Write-Host "Successfully created Azure Container App environment named : $environmentName "  -ForegroundColor Yellow

#Setup Pub Sub Dapr component
Write-Host "Creating Dapr Pubsub component "  -ForegroundColor Yellow

az containerapp env dapr-component set `
    --name $environmentName --resource-group $resourceGroupName `
    --dapr-component-name rabbitmq-pubsub `
    --yaml ../k8s/Dapr-components/rabbitmq-dapr.yaml

Write-Host "Successfully created Dapr Pubsub component "  -ForegroundColor Yellow

# Create Azure Container App for TechTalks Producer application
Write-Host "Creating Azure Container App for Producer "  -ForegroundColor Yellow

az containerapp create `
    --environment $environmentName `
    --resource-group $resourceGroupName `
    --name tech-talks-producer `
    --image ngacrregistry.azurecr.io/nileshgule/techtalksproducer:dapr `
    --registry-server ngacrregistry.azurecr.io `
    --target-port 80 `
    --ingress 'external' `
    --enable-dapr `
    --dapr-app-id rabbitmq-producer `
    --dapr-app-port 80 `
  
    
#--query configuration.ingress.fqdn
    
Write-Host "Successfully created Azure Container App for Producer "  -ForegroundColor Yellow

#verify deployment

$LOG_ANALYTICS_WORKSPACE_CLIENT_ID = az containerapp env show `
    --name $environmentName `
    --resource-group $resourceGroupName `
    --query properties.appLogsConfiguration.logAnalyticsConfiguration.customerId `
    --out tsv

az monitor log-analytics query `
    --workspace $LOG_ANALYTICS_WORKSPACE_CLIENT_ID `
    --analytics-query "ContainerAppConsoleLogs_CL | where ContainerAppName_s == 'tech-talks-producer' | project ContainerAppName_s, Log_s, TimeGenerated" `
    --out table

