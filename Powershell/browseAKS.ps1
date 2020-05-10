Param(
    [parameter(Mandatory = $false)]
    [string]$resourceGroupName = "demo-aks-vnodeRG",
    [parameter(Mandatory = $false)]
    [string]$clusterName = "aksVNodeCluster"
)

# Browse AKS dashboard
Write-Host "Browse AKS cluster $clusterName" -ForegroundColor Yellow
az aks browse `
    --resource-group=$resourceGroupName `
    --name=$clusterName