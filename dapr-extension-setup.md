# Steps required for setting up Dapr extension on AKS cluster

## Register providers

```powershell

az provider register --namespace Microsoft.Kubernetes

az provider register --namespace Microsoft.KubernetesConfiguration

```

Registration will take some time, confirm the providers are configured by running 

```powershell

az provider show -n Microsoft.Kubernetes -o table

az provider show -n Microsoft.KubernetesConfiguration -o table

```

## Install Dapr extension on AKS cluster

Execute the [install-dapr-extension](/Powershell/install-dapr-extension.ps1) powershell script

## Additional resources

- [Zipkin Setup](https://docs.dapr.io/operations/monitoring/tracing/setup-tracing/)
- [Dapr pub Sub RabbitMQ example](https://docs.dapr.io/developing-applications/building-blocks/pubsub/howto-publish-subscribe/)
- [RabbitMQ spec fields](https://v1-0.docs.dapr.io/operations/components/setup-pubsub/supported-pubsub/setup-rabbitmq/)
- [Dapr setup extension for AKS](https://docs.dapr.io/developing-applications/integrations/azure/azure-kubernetes-service-extension/)