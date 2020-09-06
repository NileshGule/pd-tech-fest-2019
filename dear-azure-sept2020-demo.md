# Dear Azure Demo

## Switch context between Kubernetes clusters

```Powershell

kubectl config get-contexts

kubectl config set current-context aksCluster

kubectl config set current-context aksVNodeCluster

kubectl config set current-context aksLiveDemoCluster

# kubectl config set current-context aksLiveDemoVNodeCluster

```

## Demo 1 - KEDA Autoscaler

### Provision AKS cluster named `aksCluster`

Run the `[initializeAKS](https://github.com/NileshGule/sample-dotnet-core-rabbitmq-keda/blob/master/Powershell/initializeAKS.ps1)` Powershell script to provision AKS Cluster

```Powershell

.\initializeAKS.ps1 `
-resourceGroupName "demo-dear-azure-aksRG" `
-clusterName "aksCluster"

```

Provision cluster for live demo

```Powershell

.\initializeAKS.ps1 `
-resourceGroupName "demo-dear-azure-aksRG" `
-clusterName "aksLiveDemoCluster"

```

Deploy RabbitMQ using `[deployRabbitMQ.ps1](Powershell\deployRabbitMQ.ps1)` Powershell script

```powershell

.\deployRabbitMQ.ps1

```

Deploy TechTalks using `[deployTechTalks-AKS.ps1](Powershell\deployTechTalks-AKS.ps1)` Powershell script

```powershell

.\deployTechTalks-AKS.ps1

```

Deploy KEDA using `[deployTechTalks-AKS.ps1](Powershell\deployKEDA.ps1)` Powershell script

```powershell

.\deployKEDA.ps1

```

Deploy KEDA Autoscaler using `[deployTechTalks-AKS.ps1](Powershell\deployAutoScaler.ps1)` Powershell script

```powershell

.\deployautoScaler.ps1

```

Port forward to RabbitMQ Management UI

```Powershell

kubectl port-forward svc/rabbitmq 15672:15672

```

Get pods related to KEDA

```powershell

kubectl get pods --namespace keda

kubectl get crd --namespace keda

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
