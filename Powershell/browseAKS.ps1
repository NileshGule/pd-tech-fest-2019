Param(
    [parameter(Mandatory = $false)]
    [string]$resourceGroupName = "demo-kedaSeriesRG",
    [parameter(Mandatory = $false)]
    [string]$clusterName = "aksmqCluster"
)

# Browse AKS dashboard
Write-Host "Browse AKS cluster $clusterName" -ForegroundColor Yellow
az aks browse `
    --resource-group=$resourceGroupName `
    --name=$clusterName