Write-Host "Starting deployment of RabbitMQ using Helm" -ForegroundColor Yellow

helm repo add bitnami https://charts.bitnami.com/bitnami
# helm repo add azure-marketplace https://marketplace.azurecr.io/helm/v1/repo

helm repo update

helm install rabbitmq `
    --version 8.15.2 `
    --set auth.username=user `
    --set auth.password=PASSWORD `
    --set auth.erlangCookie=c2VjcmV0Y29va2ll `
    bitnami/rabbitmq
# azure-marketplace/rabbitmq
    
Write-Host "Deployment of RabbitMQ using Helm completed successfully" -ForegroundColor Yellow