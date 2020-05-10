Param(
    [parameter(Mandatory = $false)]
    [string]$subscriptionName = "Microsoft Azure Sponsorship",
    [parameter(Mandatory = $false)]
    [string]$resourceGroupName = "demo-kedaSeriesRG",
    [parameter(Mandatory = $false)]
    [string]$resourceGroupLocaltion = "South East Asia",
    [parameter(Mandatory = $false)]
    [string]$clusterName = "aksmqCluster",
    [parameter(Mandatory = $false)]
    [int16]$workerNodeCount = 2,
    [parameter(Mandatory = $false)]
    [string]$kubernetesVersion = "1.11.2"

)

# Set Azure subscription name
Write-Host "Setting Azure subscription to $subscriptionName"  -ForegroundColor Yellow
az account set --subscription=$subscriptionName

# Create resource group name
Write-Host "Creating resource group $resourceGroupName in region $resourceGroupLocaltion" -ForegroundColor Yellow
az group create `
    --name=$resourceGroupName `
    --location=$resourceGroupLocaltion `
    --output=jsonc

# $SUBSCRIPTION = $(Get-AzureSubscription -SubscriptionName $subscriptionName).SubscriptionId

# # Create Service Principal, storing the JSON to grab two vars next
# # $SERVICE_PRINCIPAL = $(az ad sp create-for-rbac `
# #         --name kedasp `
# #         --scope /subscriptions/$SUBSCRIPTION/resourceGroups/$resourceGroupName `
# #         --role Contributor `
# #         --skip-assignment `
# #         --output json)

# # Create Service Principal
# $password = $(az ad sp create-for-rbac `
#         --name kedasp `
#         --skip-assignment `
#         --query password `
#         --output tsv)

# # Assign permissions to Virtual Network
# $appId = $(az ad sp list --display-name kedasp --query [].appId -o tsv)

# # Get the AKS SP ID from the service principal JSON
# $AKS_SP_ID = $(az ad sp list --display-name kedasp --query [].appId -o tsv)
# Write-Host "SP ID : $appId"

# # Get the AKS SP pass from the service principal JSON
# $AKS_SP_PASS = $(az ad sp list --display-name kedasp --query [].password -o tsv)
# Write-Host "SP PWD : $password"

# Create AKS cluster
Write-Host "Creating AKS cluster $clusterName with resource group $resourceGroupName in region $resourceGroupLocaltion" -ForegroundColor Yellow
az aks create `
    --resource-group=$resourceGroupName `
    --name=$clusterName `
    --node-count=$workerNodeCount `
    --enable-managed-identity `
    --output=jsonc
# --disable-rbac `

# Get credentials for newly created cluster
Write-Host "Getting credentials for cluster $clusterName" -ForegroundColor Yellow
az aks get-credentials `
    --resource-group=$resourceGroupName `
    --name=$clusterName `
    --overwrite-existing

Write-Host "Successfully created cluster $clusterName with $workerNodeCount node(s)" -ForegroundColor Green

Write-Host "Creating cluster role binding for Kubernetes dashboard" -ForegroundColor Green

kubectl create clusterrolebinding kubernetes-dashboard `
    -n kube-system `
    --clusterrole=cluster-admin `
    --serviceaccount=kube-system:kubernetes-dashboard

Set-Location ~/projects/pd-tech-fest-2019/Powershell