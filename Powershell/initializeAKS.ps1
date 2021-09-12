Param(
    [parameter(Mandatory = $false)]
    [string]$subscriptionName = "Microsoft Azure Sponsorship",
    [parameter(Mandatory = $false)]
    [string]$resourceGroupName = "demo-live-kl-rg",
    [parameter(Mandatory = $false)]
    [string]$resourceGroupLocaltion = "South East Asia",
    [parameter(Mandatory = $false)]
    [string]$clusterName = "azure-kl-live-demo-cluster",
    [parameter(Mandatory = $false)]
    [int16]$workerNodeCount = 3,
    [parameter(Mandatory = $false)]
    [string]$kubernetesVersion = "1.21.2",
    [parameter(Mandatory = $false)]
    [string]$acrRegistryName = "ngAcrRegistry"
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

$aks = az aks show `
    --name $clusterName `
    --resource-group $resourceGroupName `
    --query name | ConvertFrom-Json

$aksCLusterExists = $aks.Length -gt 0

if ($aksCLusterExists -eq $false) {
    # Create AKS cluster
    Write-Host "Creating AKS cluster $clusterName with resource group $resourceGroupName in region $resourceGroupLocaltion" -ForegroundColor Yellow
    az aks create `
        --resource-group=$resourceGroupName `
        --name=$clusterName `
        --node-count=$workerNodeCount `
        --enable-managed-identity `
        --output=jsonc `
        --kubernetes-version=$kubernetesVersion `
        --attach-acr=$acrRegistryName 
        # --aks-custom-headers="CustomizedUbuntu=aks-ubuntu-1804,ContainerRuntime=containerd" `

    #check the status of last command
    if (!$?) {
        Write-Error "Error creating ASK cluster" -ErrorAction Stop
    }

}
# Get credentials for newly created cluster
Write-Host "Getting credentials for cluster $clusterName" -ForegroundColor Yellow
az aks get-credentials `
    --resource-group=$resourceGroupName `
    --name=$clusterName `
    --overwrite-existing

Write-Host "Successfully created cluster $clusterName with $workerNodeCount node(s)" -ForegroundColor Green

# Write-Host "Creating cluster role binding for Kubernetes dashboard" -ForegroundColor Green

# kubectl create clusterrolebinding kubernetes-dashboard `
#     -n kube-system `
#     --clusterrole=cluster-admin `
#     --serviceaccount=kube-system:kubernetes-dashboard

Set-Location ~/projects/pd-tech-fest-2019/Powershell