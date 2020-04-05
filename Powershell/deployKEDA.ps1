# helm repo add kedacore https://kedacore.azureedge.net/helm
helm repo add kedacore https://kedacore.github.io/charts

helm repo update

# Wait for 30 seconds for the tiller service to be available in the cluster
# If tiller is not available, Keda installation fails
# In case of Keda failure, the helm install command given below can be executed manually
Start-Sleep -Seconds 30

Write-Host "Initializing KEDA on AKS cluster $clusterName" -ForegroundColor Green

kubectl create namespace keda

helm install keda `
    kedacore/keda `
    --namespace keda

# helm install kedacore/keda-edge `
#     --devel `
#     --set logLevel=debug `
#     --namespace keda `
#     --name keda

Set-Location ~/projects/pd-tech-fest-2019/Powershell