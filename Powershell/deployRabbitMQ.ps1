Write-Host "Starting deployment of RabbitMQ using Helm" -ForegroundColor Yellow

helm repo add bitnami https://charts.bitnami.com/bitnami

helm repo update

helm install rabbitmq `
    --set auth.username=user `
    --set auth.password=PASSWORD `
    bitnami/rabbitmq
# azure-marketplace/rabbitmq

Write-Host "Deployment of RabbitMQ using Helm completed successfully" -ForegroundColor Yellow