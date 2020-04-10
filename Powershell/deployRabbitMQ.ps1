Write-Host "Starting deployment of RabbitMQ using Helm" -ForegroundColor Yellow

helm install rabbitmq `
    --set rabbitmq.username=user `
    --set rabbitmq.password=PASSWORD `
    azure-marketplace/rabbitmq

Write-Host "Deployment of RabbitMQ using Helm completed successfully" -ForegroundColor Yellow