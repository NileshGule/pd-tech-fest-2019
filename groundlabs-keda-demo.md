# Ground Labs KEDA Demo

## Switch context between Kubernetes clusters

```Powershell

kubectl config set current-context aksmqCluster

kubectl config set current-context aksKedaCluster

```

## Demo 1 - Azure Functions with Virtual Node

### Provision AKS cluster named `rabbitmqCluster`

Run the `[initializeAKS](https://github.com/NileshGule/sample-dotnet-core-rabbitmq-keda/blob/master/Powershell/initializeAKS.ps1)` Powershell script to provision AKS Cluster

```Powershell

.\initializeAKS.ps1

```

```Powershell

.\browseAKS.ps1 `
-resourceGroupName "kedaResourceGroup" `
-clusterName "aksKedaCluster"

```

## Demo 2 - RabbitMQ consumer

### Provision AKS cluster named `rabbitmqCluster`

Run the `[initializeAKS](Powershell\initializeAKS.ps1)` Powershell script to provision AKS Cluster

```Powershell

.\initializeAKS.ps1 `
-resourceGroupName "rabbitmq-rg" `
-clusterName "rabbitmqCluster"

```

Deploy RabbitMQ using `[deployRabbitMQ.ps1](Powershell\deployRabbitMQ.ps1)` Powershell script

```powershell

.\deployRabbitMQ.ps1

```

Deploy TechTalks using `[deployTechTalks-AKS.ps1](Powershell\deployTechTalks-AKS.ps1)` Powershell script

```powershell

.\deployTechTalks-AKS.ps1

```

Browse Kubernetes dashboard

```Powershell

.\browseAKS.ps1 `
-resourceGroupName "rabbitmq-rg" `
-clusterName "rabbitmqCluster"

```

Port forward to RabbitMQ Management UI

```Powershell

kubectl port-forward svc/rabbitmq 15672:15672

```

## Delete AKS cluster

```Powershell

.\deleteRG.ps1 `
-resourceGroupName "rabbitmq-rg"

.\deleteRG.ps1 `
-resourceGroupName "kedaResourceGroup"

```

## Install Helm

**Note:** _Helm 2.14_ version has problems creating the Custom Resource Definition for KEDA related objects. Install the stable version of `Helm 2.13.1`

```Powershell

choco install kubernetes-helm --version 2.13.1

```

## Backup incase of firewall restriction with POST requests

```Powershell

$postParams = @{
 "Id"="1"
} | ConvertTo-Json

Invoke-WebRequest -Uri http://104.215.188.111:8080/api/TechTalks -Method POST -ContentType "application/json" -Body $postParams

```

To Access the RabbitMQ AMQP port:

```powershell

kubectl port-forward --namespace default svc/rabbitmq 5672:5672
echo "URL : amqp://127.0.0.1:5672/"

```

To Access the RabbitMQ Management interface:

```powershell

kubectl port-forward --namespace default svc/rabbitmq 15672:15672
echo "URL : http://127.0.0.1:15672/"

```
