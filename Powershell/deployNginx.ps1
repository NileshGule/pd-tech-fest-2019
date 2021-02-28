# Add the ingress-nginx repository
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

helm repo update

Write-Host "Initializing NGINX Ingress on AKS cluster $clusterName" -ForegroundColor Green

# kubectl create namespace ingress-basic

# Use Helm to deploy an NGINX ingress controller
helm upgrade nginx-ingress ingress-nginx/ingress-nginx `
    --namespace default `
    --set controller.replicaCount=2 `
    --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux `
    --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux `
    --set controller.admissionWebhooks.patch.nodeSelector."beta\.kubernetes\.io/os"=linux `
    --set controller.customPorts="8085"

Set-Location ~/projects/pd-tech-fest-2019/Powershell