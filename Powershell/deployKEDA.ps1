helm repo add kedacore https://kedacore.github.io/charts

helm repo update

Write-Host "Initializing KEDA on AKS cluster $clusterName" -ForegroundColor Green

#Helm 3 syntax
helm upgrade --install keda `
    kedacore/keda `
    --version 2.4.0 `
    --create-namespace `
    --namespace keda

Set-Location ~/projects/pd-tech-fest-2019/Powershell