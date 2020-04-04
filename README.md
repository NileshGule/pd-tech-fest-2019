# pd-tech-fest-2019

Demo code for [Programmers Developers Tech Fest 2019](https://www.eventbrite.com/e/pd-techfest-tickets-62965805419)

[![Scaling containers with KEDA](/images/pd-tech-fest.png)](https://www.eventbrite.com/e/pd-techfest-tickets-62965805419)

There are multiple options for scaling with Kubernetes and containers in general. This demo uses `Kubernetes-based Event Driven Autoscaling (KEDA)`. RabbitMQ is used as an event source.

## Prerequisites

- Azure Susbscription to create AKS cluster
- kubectl logged into kubernetes cluster
- Powershell
- Postman

If you wish to use Kubernetes cluster apart from AKS, you can skip the `Step 2.1` of provisioning the cluster and [install KEDA](https://github.com/kedacore/keda#setup) on your own kubernetes cluster.

Similarly, if you do not wish to execute the Powershell scripts, you can execute teh commands which are part of those scripts manually.

## 1 - Code organization

- [src](src)

Contains the source code for a model classes for a hypothetical Tech Talks management application. `TechTalksAPI` contains the code for generating the events / messages which are published to a RabbitMQ queue. `TechTalksMQConsumer` contains the consumer code for processing RabbitMQ messages.

Both the Producer and Consumer uses the common data model. In order to build these using Dockerfile, we define the [TechTalksAPI](/src/Dockerfile-TechTalksAPI) and [TechTalksMQConsumer](/src/Dockerfile-TechTalksMQConsumer). These are built [docker-compose-build](/src/docker-compose-build.yml) file.

The docker images can be built using the following command

```powershell

docker-compose -f docker-compose-build.yml build

```

Once the images are built successfully, we can push them to the DockerHub reistry using the command

```powershell

docker-compose -f docker-compose-build.ym push

```

- [Powershell](Powersehll)

Contains the helper Poweshell scripts to provision AKS cluster, to proxy into the Kubernetes control plane, to delete the resource group, to deploy the application and also to delete the application.

- [k8s](k8s)

Contains Kubernetes manifest files for deploying the Producer and Consumer components to the Kubernetes cluster.

- [helm](helm)

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

As we can see above, RabbitMQ service is available within the Kubernetes cluster and it exposes `4369`, `5672`, `25672` and `15672` ports. We will be using `15672` port to map to a local port.

Also note the public `LoadBalancer` IP for the techtalksapi service. In this case the IP is **`13.67.52.226`**.
**Note:** This IP will be different when the services are redeployed on a different Kubernetes cluster.

### 2.5 Watch for deployments

The rabbitmq `ScaledObject` will be deployed as part of the deployment. Watch out for the deployments to see the changes in the scaling as the number of messages increases

```code

kubectl get deployment -w

kubectl get deploy -w

```

![List of all Kubernetes services](/images/initial-deploy-state.png)

Initially there is 1 instance of rabbitmq-consumer and 2 replicas of the techtalksapi (producer) deployed in the cluster.

### 2.6 Port forward for RabbitMQ management UI

We will use port forwarding approach to access the RabbitMQ management UI.

```code

kubectl port-forward svc/rabbitmq 15672:15672

```

### 2.7 Browse RabbitMQ Management UI

http://localhost:15672/

Login to the management UI using credentials as `user` and `PASSWORD`. Remember that these were set duing the installation of RabbitMQ services using Helm. If you are using any other user, please update the username and password accordingly.

### 2.8 Generate load using `Postman`

I am using [Postman](https://www.getpostman.com/) to submit a POST request to the API which generates 1000 messages onto a RabbitMQ queue named `hello`. You can use any other command line tool like CURL to submit a POST request.

Use the `EXTERNAL-IP -13.67.52.226` with port `8080` to submit a post request to the API. http://13.67.52.226:8080/api/TechTalks/

Make sure to set the method to `POST` and add the header with key as `Content-Type` and value as `application/json`. Also specify the body with a random integer as shown below.

![postman header](/images/postman-header.png)

![postman body](/images/postman-body.png)

After building the POST query, hit the blue `Send` button on the top right. If everything goes fine, you should receive a `200 OK` as status code.

![postman success](/images/postman-success.png)

The Producer will produce 1000 messages on the queue named `hello`. The consumer is configured to process `10` messages in a batch. The consumer also simulates a long running process by sleeping for `2 seconds`.

### 2.9 Auto-scaling in action

See the number of containers for consumer grow to adjust the messages and also the drop when messages are processed.

![autoscaling consumers](/images/autoscaling.png)

While the messages are being processed, we can also observe the RabbitMQ management UI.

![autoscaling consumers](/images/RabbitMQ-managementUI.PNG)

Our consumer processes 10 messages in a batch by prefetching them together. This can be verified by looking at the details of the consumers.

![Prefetch messages](/images/rabbitMQ-prefetch.PNG)

List Custom Resource Definition

```code

kubeclt get crd

```

---

## Slides

Here are the links to slides from the presentation

### Slideshare

[![Scaling containers with KEDA](/images/slideshare.PNG)](https://www.slideshare.net/nileshgule/scaling-containers-with-keda)

### Speakerdeck

[![Scaling containers with KEDA](/images/speakerdeck.PNG)](https://speakerdeck.com/nileshgule/scaling-containers-with-keda)
