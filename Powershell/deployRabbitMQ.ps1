# TO DO
# Add step for installing RabbitMQ using Helm

Write-Host "Starting deployment of RabbitMQ using Helm" -ForegroundColor Yellow

helm install `
    --name rabbitmq `
    --set rabbitmq.username=user `
    --set rabbitmq.password=PASSWORD `
    stable/rabbitmq

Write-Host "Deployment of RabbitMQ using Helm completed successfully" -ForegroundColor Yellow