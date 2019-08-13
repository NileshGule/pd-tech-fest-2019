# pd-tech-fest-2019

Demo code for [Programmers Developers Tech Fest 2019](https://www.eventbrite.com/e/pd-techfest-tickets-62965805419)

[![Scaling containers with KEDA](/images/pd-tech-fest.png)](https://www.eventbrite.com/e/pd-techfest-tickets-62965805419)

There are multiple options for scaling with Kubernetes and containers in general. This demo uses `Kubernetes-based Event Driven Autoscaling (KEDA)`. RabbitMQ is used as an event source.

## 1 - Code organization

- [src](src)

Contains the source code for a model classes for a hypothetical Tech Talks management application. `TechTalksAPI` contains the code for generating the events / messages which are published to a RabbitMQ queue. `TechTalksMQConsumer` contains the consumer code for processing RabbitMQ messages.

Both the Producer and Consumer uses the common data model. In order to build these using Dockerfile, we define the [TechTalksAPI](/src/Dockerfile-TechTalksAPI) and [TechTalksMQConsumer](/src/Dockerfile-TechTalksMQConsumer). These are built [docker-compose-build](/src/docker-compose-build.yml) file.

- [Powershell](Powersehll)

Contains the helper Poweshell scripts to provision AKS cluster, to proxy into the Kubernetes control plane, to delete the resource group, to deploy the application and also to delete the application.

- [k8s](k8s)

Contains Kubernetes manifest files for deploying the Producer and Consumer components to the Kubernetes cluster.

- [heml](helm)

Contains the Helm RBAC enabling yaml file which add the Cluster Role Binding for RBAC enabled Kubernetes cluster.

---

## 2 - Demo setup

### 2.1 Initialize AKS cluster with KEDA

Run [initializeAKS](/Powershell/initializeAKS.ps1) powershell script with default values from Powershell directory

```powershell

.\initializeAKS.ps1

```

Note: The default options can be overwritten by passing arguments to the initializeAKS script. In the below example, we are overriding the number of nodes in the AKS cluster to 4 instead of 3 and resource group name as `kedaresgrp`.

```powershell

.initilaizeAKS `
-workerNodeCount 4 `
-resourceGroupName "kedaresgrp"

```

Verify KEDA is installed correctly on the Kubernetes cluster.

```code

kubectl get all -n keda

```

### 2.2 Deploy RabbitMQ queue

```code

helm install --name rabbitmq --set rabbitmq.username=user,rabbitmq.password=PASSWORD stable/rabbitmq

```

### 2.3 Deploy RabbitMQ Producer & Consumers

Execute the `deployTechTalks-AKS.ps1` powershell script.

```powershell

.\deployTechTalks-AKS.ps1

```

The `deployTechTalks` powershell script deploys the RabbitMQConsumer and RabbitMQProducer in the correct order. Alternately, all the components can also be deployed directly using the `kubectl` apply command recursively on the k8s directory as shown below.

Run the kubectl apply recursively on k8s directory

```code

kubectl apply -R -f .

```

### 2.4 Get list of all the services deployed in the cluster

We will need to know the service name for RabbitMQ to be able to do port forwarding to the RabbitMQ management UI and also the public IP assigned to the TechTalks producer service which will be used to generate the messages onto RabbitmQ queue.

```code

kubectl get svc

```

![List of all Kubernetes services](/images/all-services.png)

As we can see above, RabbitMQ service is available within the Kubernetes cluster and it exposes 4369, 5672, 25672 and 15672 ports. We will be using 15672 port to map to a local port.

Also note the public `LoadBalancer` IP for the techtalksapi service. In this case the IP is **`13.67.52.226`**.
**Note:** This IP will be different when the services are redeployed on a different Kubernetes cluster.

### Watch for deployments

The rabbitmq ScaledObject will be deployed as part of the deployment. Watch out for the deployments to see the changes in the scaling as the number of messages increases

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

Here are the links to slides from the presentation

Slideshare

[![Scaling containers with KEDA](/images/slideshare.PNG)](https://www.slideshare.net/nileshgule/scaling-containers-with-keda)

Speakerdeck

[![Scaling containers with KEDA](/images/speakerdeck.PNG){:height="100px" width="100px"}](https://speakerdeck.com/nileshgule/scaling-containers-with-keda)
