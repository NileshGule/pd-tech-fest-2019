# Setup for Azure Container Apps

## Setup Azure CLI extensions

### Install Azure Container Apps extension for the CLI

```code

az extension add --name containerapp --upgrade

```

### Register the `Microsoft.App` namespace

```code

az provider register --namespace Microsoft.App

```

### Register the `Microsoft.OperationalInsights` provider for the Azure Monitor Log Analytics workspace

```code

az provider register --namespace Microsoft.OperationalInsights

```
