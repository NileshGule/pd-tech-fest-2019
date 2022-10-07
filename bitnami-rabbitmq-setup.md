# Bitnami RabbitMQ setup on Azure

## Create RabbitMQ server

- https://cloudinfrastructureservices.co.uk/how-to-setup-rabbitmq-on-windows-server-in-azure-aws-gcp/

- https://github.com/Azure-Samples/azure-spring-cloud/blob/master/docs/create-mongodb-and-rabbitmq.md

## Expose ports related to RabbitMQ

- https://docs.bitnami.com/azure/infrastructure/rabbitmq/get-started/understand-default-config/

```Powershell

az vm open-port --port 5672 --name rabbitmq  `
    --resource-group azure-container-app-rg

az vm open-port --port 15672 --name rabbitmq `
    --resource-group azure-container-app-rg --priority 1100

```

## Link on creating RabbitMQ server using Azure CLI

https://learn.microsoft.com/en-us/azure/virtual-machines/linux/cli-ps-findimage

## Link to issue related to Dapr consumer for RabbitMQ

https://stackoverflow.com/questions/65512137/dapr-binding-for-rabbitmq-not-working-using-dapr-pub-sub-sample
