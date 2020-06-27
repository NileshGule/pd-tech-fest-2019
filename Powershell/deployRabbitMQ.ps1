Write-Host "Starting deployment of RabbitMQ using Helm" -ForegroundColor Yellow

helm install rabbitmq `
    --set auth.username=user `
    --set auth.password=PASSWORD `
    bitnami/rabbitmq
    # azure-marketplace/rabbitmq

Write-Host "Deployment of RabbitMQ using Helm completed successfully" -ForegroundColor Yellow