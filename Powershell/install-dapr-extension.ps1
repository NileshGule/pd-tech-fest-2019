Param(
    [parameter(Mandatory = $false)]
    [string]$resourceGroupName = "azure-container-app-rg",
    [parameter(Mandatory = $false)]
    [string]$clusterName = "azure-singapore-cluster"
)

# Add dapr extension to AKS cluster
Write-Host "Adding Dapr extension to AKS cluster $clusterName"  -ForegroundColor Yellow

az extension add --name k8s-extension

az k8s-extension create `
    --cluster-type managedClusters `
    --cluster-name $clusterName `
    --resource-group $resourceGroupName `
    --name myDaprExtension `
    --extension-type Microsoft.Dapr `
    --auto-upgrade-minor-version true


#check the status of last command
if (!$?) {
    Write-Error "Error creating Dapr extension for $clusterName" -ErrorAction Stop
}


Write-Host "Successfully added Dapr extension to cluster $clusterName " -ForegroundColor Green

Set-Location ~/projects/pd-tech-fest-2019/Powershell