Param(
    [parameter(Mandatory = $false)]
    [string]$subscriptionName = "Microsoft Azure Sponsorship",
    [parameter(Mandatory = $false)]
    [string]$resourceGroupName = "aazureaugustUGRG",
    [parameter(Mandatory = $false)]
    [string]$resourceGroupLocaltion = "South East Asia",
    [parameter(Mandatory = $false)]
    [string]$clusterName = "aksCluster",
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

# Create AKS cluster
Write-Host "Creating AKS cluster $clusterName with resource group $resourceGroupName in region $resourceGroupLocaltion" -ForegroundColor Yellow
az aks create `
    --resource-group=$resourceGroupName `
    --name=$clusterName `
    --node-count=$workerNodeCount `
    --disable-rbac `
    --output=jsonc
# --kubernetes-version=$kubernetesVersion `

# Get credentials for newly created cluster
Write-Host "Getting credentials for cluster $clusterName" -ForegroundColor Yellow
az aks get-credentials `
    --resource-group=$resourceGroupName `
    --name=$clusterName

Write-Host "Successfully created cluster $clusterName with kubernetes version $kubernetesVersion and $workerNodeCount node(s)" -ForegroundColor Green

Write-Host "Creating cluster role binding for Kubernetes dashboard" -ForegroundColor Green

kubectl create clusterrolebinding kubernetes-dashboard `
    -n kube-system `
    --clusterrole=cluster-admin `
    --serviceaccount=kube-system:kubernetes-dashboard

Write-Host "Creating Tiller service account for Helm" -ForegroundColor Green

# source common variables
. .\var.ps1

Set-Location $helmRootDirectory

kubectl apply -f .\helm-rbac.yaml

Write-Host "Initializing Helm with Tiller service account" -ForegroundColor Green

helm init --service-account tiller

helm repo add kedacore https://kedacore.azureedge.net/helm

helm repo update

# Wait for 30 seconds for the tiller service to be available in the cluster
# If tiller is not available, Keda installation fails
# In case of Keda failure, the helm install command given below can be executed manually
Start-Sleep -Seconds 30

Write-Host "Initializing KEDA on AKS cluster $clusterName" -ForegroundColor Green

helm install kedacore/keda-edge `
    --devel `
    --set logLevel=debug `
    --namespace keda `
    --name keda

Set-Location ~/projects/pd-tech-fest-2019/Powershell