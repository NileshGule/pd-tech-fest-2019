# Demo setup for [reskill.com / Azure Developer Community](https://reskilll.com/event/autoscalecontainers) on 29th January 2022

## Setup for Scaling .Net containers with event driven workloads talk
## Initialize AKS cluster with all KEDA related resources

Run the [deployAll](/Powershell/deployAll.ps1) Powershell script which setup everything from AKS cluster, RabbitMQ, KEDA, TechTalks services etc.

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

Got the IP as `20.195.103.121`

## Produce messages on the RabbitMQ

Use Postman to generate 5000 messages

```

http://20.195.103.121/api/TechTalks/Generate?numberOfMessages=5000

```

Other options can also be used to produce messages like hitting the above url directly from browser or using command line utilities like curl or wget 

## Watch the rabbitmq-consumer scale

```code

kubectl get pods --watch

kubectl get deploy --watch

```

## Scale consumer deployment to 2 replicas

```

kubectl scale deployment rabbitmq-consumer-deployment --replicas=2

```

## create HPA with 75% CPU usage

```code

kubectl autoscale deployment rabbitmq-consumer-deployment --cpu-percent=75 --min=1 --max=10

```

## Delete HPA

```

kubectl delete hpa rabbitmq-consumer-deployment

```

## Deploy KEDA Autoscaler

```powershell

.\deployAutoScaler.ps1

```

## Verify KEDA Custom Resource Definitions

```powershell

kubectl get crd

```