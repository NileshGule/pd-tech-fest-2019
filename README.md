# pd-tech-fest-2019

Demo code for [Programmers Developers Tech Fest 2019](https://www.eventbrite.com/e/pd-techfest-tickets-62965805419)

## Demo setup

### Initialize AKS cluster with KEDA

Run initializeAKS powershell script with default values from Powershell directory

```powershell

.\initializeAKS.ps1

```

Query Kubernetes resources deployed by KEDA

```code

kubectl get all -n keda

```

### Deploy RabbitMQ queue

```code

helm install --name rabbitmq --set rabbitmq.username=user,rabbitmq.password=PASSWORD stable/rabbitmq

```

### Deploy RabbitMQ Producer & Consumers

Run the kubectl apply recursively on k8s directory

```code

kubectl apply -R -f .

```

Watch for deployments

```code

kubectl get deployment -w

kubectl get deploy -w

```

Port forward for RabbitMQ management UI

```code

kubectl port-forward svc/rabbitmq 15672:15672

```

Browse RabbitMQ Management UI

http://localhost:15672/

List Custom Resource Definition

```code

kubeclt get crd

```
