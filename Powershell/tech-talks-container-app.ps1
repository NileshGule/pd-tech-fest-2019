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

# # Create Azure Container App environment
# Write-Host "Creating Azure Container App environment named : $environmentName "  -ForegroundColor Yellow

# az containerapp env create `
#     --name $environmentName `
#     --resource-group $resourceGroupName `
#     --location $resourceGroupLocaltion

# Write-Host "Successfully created Azure Container App environment named : $environmentName "  -ForegroundColor Yellow

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
    --name techtalks-producer `
    --image ngacrregistry.azurecr.io/nileshgule/techtalksproducer:dapr `
    --registry-server ngacrregistry.azurecr.io `
    --target-port 80 `
    --ingress 'external' `
    --enable-dapr `
    --dapr-app-id rabbitmq-producer `
    --dapr-app-port 80 `
    --min-replicas 1 `
    --max-replicas 3
  
    
#--query configuration.ingress.fqdn
    
Write-Host "Successfully created Azure Container App for Producer "  -ForegroundColor Yellow

# Create Azure Container App for TechTalks Producer application
Write-Host "Creating Azure Container App for Consumer "  -ForegroundColor Yellow

az containerapp create `
    --environment $environmentName `
    --resource-group $resourceGroupName `
    --name techtalks-consumer `
    --image ngacrregistry.azurecr.io/nileshgule/techtalksconsumer:dapr `
    --registry-server ngacrregistry.azurecr.io `
    --target-port 80 `
    --ingress 'internal' `
    --enable-dapr `
    --dapr-app-id rabbitmq-consumer `
    --dapr-app-port 80 `
    --min-replicas 1 `
  
    
#--query configuration.ingress.fqdn
    
Write-Host "Successfully created Azure Container App for Consumer "  -ForegroundColor Yellow

##Create a new secret named 'svcbus-connstring' in backend processer container app
az containerapp secret set `
    --name techtalks-consumer `
    --resource-group $resourceGroupName `
    --secrets "rabbitmq-host=amqp://user:tCUN6UizuwTZ@20.24.98.54:5672/"

# define KEDA autoscaler

az containerapp update `
    --name techtalks-consumer `
    --resource-group $resourceGroupName `
    --min-replicas 1 `
    --max-replicas 15 `
    --scale-rule-name "queue-length" `
    --scale-rule-type "rabbitmq" `
    --scale-rule-auth "host=rabbitmq-host" `
    --scale-rule-metadata "queueName=rabbitmq-consumer-techtalks" `
    "mode=QueueLength" `
    "value=50" `
    "protocol=amqp" `
    "hostFromEnv=rabbitmq-host"

# ##Query Number & names of Replicas
# az containerapp replica list `
#     --name techtalks-consumer `
#     --resource-group azure-container-app-rg `
#     --query [].name

#verify deployment

# $LOG_ANALYTICS_WORKSPACE_CLIENT_ID = az containerapp env show `
#     --name $environmentName `
#     --resource-group $resourceGroupName `
#     --query properties.appLogsConfiguration.logAnalyticsConfiguration.customerId `
#     --out tsv

# az monitor log-analytics query `
#     --workspace $LOG_ANALYTICS_WORKSPACE_CLIENT_ID `
#     --analytics-query "ContainerAppConsoleLogs_CL | where ContainerAppName_s == 'tech-talks-producer' | project ContainerAppName_s, Log_s, TimeGenerated" `
#     --out table

# az monitor log-analytics query `
#     --workspace 8b0a5149-3858-4a53-b05c-ecb0218b9e9a `
#     --analytics-query "ContainerAppConsoleLogs_CL | where ContainerAppName_s == 'tech-talks-producer' | project ContainerAppName_s, Log_s, TimeGenerated" `
#     --out table
    

# az containerapp env dapr-component remove `
# -g azure-container-app-rg `
# --dapr-component-name rabbitmq-pubsub `
# --name aci-dev-env