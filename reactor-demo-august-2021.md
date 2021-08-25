# Steps by step guide for Reactor Demo

## Provision AKS cluster

Clone the repo for .Net Core application
[PD Tech Fest 2019](https://github.com/NileshGule/pd-tech-fest-2019.git)

Switch to powershell directory and run the `deployAll.ps1` script

This sets up the AKS cluster with default 3 nodes and deploys TechTalks application with all its services and dependencies including RabbitMQ, KEDA, TechTalksProducer and TechTalksConsumer.

Clone the repo for Spring Boot application
[spring-boot-conference-app](https://github.com/NileshGule/spring-boot-conference-app)

Switch to the `mssql-server` branch

## Install Prometheus

Run the Powershell script `install-prometheus.ps1` from powershell folder

## Get Custom Resource Definitions (CRD) for Prometheus

```bash

kubectl get crd

```

## Setup Spring Boot app

Apply manifest files from the following folder `k8s` folder

## Setup Service & Pod monitors
For Spring Boot conference app, apply the manifest files from the `k8s/prometheus-config` folder using the command

```bash

kubectl apply -R -F .

```

For TechTalks app, apply the manifest files from the `k8s/Prometheus` folder using the same command as above

## Port forward Prometheus, Grafana & AlertManager services

```bash

kubectl port-forward --namespace monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090

kubectl port-forward --namespace monitoring svc/prometheus-kube-prometheus-alertmanager 9093:9093

kubectl --namespace monitoring port-forward svc/prometheus-grafana 80:80

```
## Import Grafana dashboards

- RabbitMQ : https://grafana.com/grafana/dashboards/10991
- Springboot : https://grafana.com/grafana/dashboards/11955
- .Net core : https://grafana.com/grafana/dashboards/13399
- .Net Core Services : https://grafana.com/grafana/dashboards/12526
- .Net Core Controller Summary : https://grafana.com/grafana/dashboards/10915

## Access Prometheus Metrics for Spring Boot App

http://20.44.227.76:8080/actuator/

http://20.44.227.76:8080/actuator/prometheus

## Access Prometheus Metrics for .Net Core App

http://20.198.210.175/metrics
## Generate load on conference API

Replace the load balancer IP

```bash

for i in `seq 1 2000`; do curl http://20.197.74.200:8080/api/v1/speakers/; done

for i in `seq 1 2500`; do curl http://20.197.74.200:8080/api/v1/sessions/; done

```

## Generate load on the .Net Core TechTalks app

```bash

http://20.198.210.175/api/TechTalks/Generate?numberOfMessages=5000

```

## Trigger Alert Manager Alert

```bash

kubectl delete -f api-deployment.yml

```

## Remove Alert Manager trigger

```bash

kubectl apply -f api-deployment.yml

```