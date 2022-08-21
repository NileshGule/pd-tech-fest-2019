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