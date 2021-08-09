Write-Host "Starting deployment of RabbitMQ using Helm" -ForegroundColor Yellow

helm repo add bitnami https://charts.bitnami.com/bitnami
# helm repo add azure-marketplace https://marketplace.azurecr.io/helm/v1/repo

helm repo update

helm upgrade --install rabbitmq `
    --version 8.15.2 `
    --set auth.username=user `
    --set auth.password=PASSWORD `
    --set auth.erlangCookie=c2VjcmV0Y29va2ll `
    --set metrics.enabled=true `
    bitnami/rabbitmq
# azure-marketplace/rabbitmq
    
Write-Host "Deployment of RabbitMQ using Helm completed successfully" -ForegroundColor Yellow

# Refer to the rabbitmq helm chart docuemntation for parameters nad more details
# https://github.com/bitnami/charts/tree/master/bitnami/rabbitmq/#installing-the-chart