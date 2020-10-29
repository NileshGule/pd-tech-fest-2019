Param(
    [parameter(Mandatory = $false)]
    [string]$subscriptionName = "Microsoft Azure Sponsorship",
    [parameter(Mandatory = $false)]
    [string]$resourceGroupName = "demo-ossconf-vnodeRG",
    [parameter(Mandatory = $false)]
    [string]$resourceGroupLocaltion = "South East Asia",
    [parameter(Mandatory = $false)]
    [string]$clusterName = "oss-vnode-cluster",
    [parameter(Mandatory = $false)]
    [int16]$workerNodeCount = 1,
    [parameter(Mandatory = $false)]
    [string]$acrRegistryName = "ngAcrRegistry",
    [parameter(Mandatory = $false)]
    [string]$acrRegistryResourceGroup = "acrResourceGroup",
    [parameter(Mandatory = $false)]
    [string]$kubernetesVersion = "1.19.0"

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

Write-Host "Creating Virtual Network"
az network vnet create `
    --resource-group $resourceGroupName `
    --name kedaVnet `
    --address-prefixes 10.0.0.0/8 `
    --subnet-name kedaAKSSubnet `
    --subnet-prefix 10.240.0.0/16 `
    --output=jsonc

# Create subnet for Virtual Node
Write-Host "Creating subnet for Virtual Node"
az network vnet subnet create `
    --resource-group $resourceGroupName `
    --vnet-name kedaVnet `
    --name kedaVirtualNodeSubnet `
    --address-prefixes 10.241.0.0/16 `
    --output=jsonc

# Create Service Principal
$password = $(az ad sp create-for-rbac `
        --name kedasp `
        --skip-assignment `
        --query password `
        --output tsv)

# Assign permissions to Virtual Network
$appId = $(az ad sp list `
        --display-name kedasp `
        --query [].appId `
        -o tsv)

# Write-Host "Password = $password"

# Get Virtual network Resource Id
$vNetId = $(az network vnet show `
        --resource-group $resourceGroupName `
        --name kedaVnet `
        --query id `
        -o tsv)

# Create Role assignment
az role assignment create `
    --assignee $appId `
    --scope $vNetId `
    --role Contributor `
    --output=jsonc

# Get AKS Subnet ID
$aksSubnetID = $(az network vnet subnet show `
        --resource-group $resourceGroupName `
        --vnet-name kedaVnet `
        --name kedaAKSSubnet `
        --query id `
        -o tsv)

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
        --network-plugin azure `
        --service-cidr 10.0.0.0/16 `
        --dns-service-ip 10.0.0.10 `
        --docker-bridge-address 172.17.0.1/16 `
        --vnet-subnet-id $aksSubnetID `
        --service-principal $appId `
        --client-secret $password `
        --enable-addons monitoring `
        --attach-acr=$acrRegistryName `
        --kubernetes-version=$kubernetesVersion `
        --aks-custom-headers="CustomizedUbuntu=aks-ubuntu-1804,ContainerRuntime=containerd" `
        --output=jsonc
}

# Enable virtual node add on
Write-Host "Enabling Virtual Node addon for cluster $clusterName" -ForegroundColor Yellow
az aks enable-addons `
    --resource-group $resourceGroupName `
    --name $clusterName `
    --addons virtual-node `
    --subnet-name kedaVirtualNodeSubnet `
    --output=jsonc

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

./create-image-pull-secret.ps1 `
    -acrRegistryName $acrRegistryName `
    -acrRegistryResourceGroup $acrRegistryResourceGroup `
    -ServicePrincipalID $appId `
    -SpPassword $password

Set-Location ~/projects/pd-tech-fest-2019/Powershell