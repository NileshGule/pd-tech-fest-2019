# Demo setup for Surati Tech Talks event 10th January 2022

## Setup for Scaling .Net containers with event driven workloads talk
## Initialize AKS cluster with all KEDA related resources

Run the `[deployAll](Powershell/deployAll.ps1)` Powershell script which setup everything from AKS cluster, RabbitMQ, KEDA, TechTalks services etc.

```code

.\deployAll.ps1

```
## Access RabbitMQ UI Port forward RabbtiMQ service

```powershell

kubectl port-forward svc/rabbitmq 15672:15672

```

Access the RabbitMQ UI with credential `user` & `PASSWORD`
http://localhost:15672

## Get IP of Producer service

Retrieve the Load Balancer IP of the `rabbitmq-producer-service`

```code

kubectl get svc

kubectl get svc rabbitmq-producer-service

```

Got the IP as `20.198.138.188`

## Produce messages on the RabbitMQ

Use Postman to generate 5000 messages

```

http://20.198.138.188/api/TechTalks/Generate?numberOfMessages=5000

```

Other options can also be used to produce messages like hitting the above url directly from browser or using command line utilities like curl or wget 

## Watch the rabbitmq-consumer scale

```code

kubectl get pods --watch

kubectl get deploy --watch

```

## Deploy KEDA Autoscaler

```powershell

.\deployAutoScaler.ps1

```

## Verify KEDA Custom Resource Definitions

```powershell

kubectl get crd

```