# pd-tech-fest-2019

Demo code for [Programmers Developers Tech Fest 2019](https://www.eventbrite.com/e/pd-techfest-tickets-62965805419)

[![Scaling containers with KEDA](/images/pd-tech-fest.png)](https://www.eventbrite.com/e/pd-techfest-tickets-62965805419)

There are multiple options for scaling with Kubernetes and containers in general. This demo uses `Kubernetes-based Event Driven Autoscaling (KEDA)`. RabbitMQ is used as an event source.

## Prerequisites

- Azure Susbscription to create AKS cluster
- kubectl logged into kubernetes cluster
- Powershell
- Postman
- Helm
- DockerHub account (optional)

If you wish to use Kubernetes cluster apart from AKS, you can skip the `Step 2.1` of provisioning the cluster and [install KEDA](https://github.com/kedacore/keda#setup) on your own kubernetes cluster.

Similarly, if you do not wish to execute the Powershell scripts, you can execute the commands which are part of those scripts manually.

## 1 - Code organization

- [src](src)

Contains the source code for a model classes for a hypothetical Tech Talks management application. `TechTalksMQProducer` contains the code for generating the events / messages which are published to a RabbitMQ queue. `TechTalksMQConsumer` contains the consumer code for processing RabbitMQ messages.

Both the Producer and Consumer uses the common data model. In order to build these using Dockerfile, we define the [TechTalksMQProducer](/src/Dockerfile-TechTalksMQProducer) and [TechTalksMQConsumer](/src/Dockerfile-TechTalksMQConsumer). These are built [docker-compose-build](/src/docker-compose-build.yml) file.

The docker images can be built using the following command

```powershell

Measure-Command { docker-compose -f docker-compose-build.yml build | Out-Default }


```

Once the images are built successfully, we can push them to the DockerHub registry using the command

```powershell

Measure-Command { docker-compose -f docker-compose-build.yml push | Out-Default }

```

- [Powershell](Powersehll)

Contains the helper Powershell scripts to provision AKS cluster, to proxy into the Kubernetes control plane, to delete the resource group, to deploy the application and also to delete the application.

- [k8s](k8s)

Contains Kubernetes manifest files for deploying the Producer, Consumer and the Autoscalar components to the Kubernetes cluster.

- [helm](helm)

Contains the Helm RBAC enabling yaml file which add the Cluster Role Binding for RBAC enabled Kubernetes cluster. This was required before Helm 3.0 for the Tiller service.With helm 3.0, Tiller is no longer required.

---

## 2 - Demo setup

### 2.1 Initialize AKS cluster with KEDA

Run [initializeAKS](/Powershell/initializeAKS.ps1) powershell script with default values from Powershell directory

```powershell

.\initializeAKS.ps1

```

Note: The default options can be overwritten by passing arguments to the initializeAKS script. In the below example, we are overriding the number of nodes in the AKS cluster to 4 instead of 3 and resource group name as `kedaresgrp`.

```powershell

.\initilaizeAKS `
-workerNodeCount 4 `
-resourceGroupName "kedaresgrp"

```

### 2.2 Deploy KEDA

```powershell

.\deployKEDA.ps1

```

Verify KEDA is installed correctly on the Kubernetes cluster.

```code

kubectl get all -n keda

```

### 2.3 Deploy RabbitMQ queue

```powershell

.\deployRabbitMQ.ps1

```

### 2.4 Deploy RabbitMQ Producer & Consumers

Execute the `deployTechTalks-AKS.ps1` powershell script.

```powershell

.\deployTechTalks-AKS.ps1

```

The `deployTechTalks` powershell script deploys the RabbitMQConsumer and RabbitMQProducer in the correct order. Alternately, all the components can also be deployed directly using the `kubectl` apply command recursively on the k8s directory as shown below.

Run the kubectl apply recursively on k8s directory

```code

kubectl apply -R -f .

```

### 2.5 Deploy Auto scalar for RabbitMQ consumer deployment

Execute the `deployAutoScaler.ps1` powershell script.

```powershell

.\deployAutoScaler.ps1

```

If you do not wish to run the individual PowerShell scripts, you can run one single script which will deploy all the necessary things by running the above scripts in correct order.

```Powershell

.\deployAll.ps1

```

### 2.6 Get list of all the services deployed in the cluster

We will need to know the service name for RabbitMQ to be able to do port forwarding to the RabbitMQ management UI and also the public IP assigned to the TechTalks producer service which will be used to generate the messages onto RabbitmQ queue.

```code

kubectl get svc

```

![List of all Kubernetes services](/images/all-services.png)

As we can see above, RabbitMQ service is available within the Kubernetes cluster and it exposes `4369`, `5672`, `25672` and `15672` ports. We will be using `15672` port to map to a local port.

Also note the public `LoadBalancer` IP for the techtalksapi service. In this case the IP is **`52.139.237.252`**.
**Note:** This IP will be different when the services are redeployed on a different Kubernetes cluster.

### 2.7 Watch for deployments

The rabbitmq `ScaledObject` will be deployed as part of the deployment. Watch out for the deployments to see the changes in the scaling as the number of messages increases

```code

kubectl get deployment -w

kubectl get deploy -w

```

![List of all Kubernetes services](/images/initial-deploy-state.png)

Initially there is 1 instance of rabbitmq-consumer and 2 replicas of the techtalksapi (producer) deployed in the cluster.

### 2.8 Port forward for RabbitMQ management UI

We will use port forwarding approach to access the RabbitMQ management UI.

```code

kubectl port-forward svc/rabbitmq 15672:15672

```

### 2.9 Browse RabbitMQ Management UI

http://localhost:15672/

Login to the management UI using credentials as `user` and `PASSWORD`. Remember that these were set during the installation of RabbitMQ services using Helm. If you are using any other user, please update the username and password accordingly.

### 2.10 Generate load using `Postman`

I am using [Postman](https://www.getpostman.com/) to submit a POST request to the API which generates 1000 messages onto a RabbitMQ queue named `hello`. You can use any other command line tool like CURL to submit a GET request.

Use the `EXTERNAL-IP -52.139.237.252` with port `8080` to submit a GET request to the API. http://52.139.237.252:8080/api/TechTalks/Generate?numberOfMessages=2000

![postman success](/images/postman-get-request.png)

Note that we are setting the number of messages to be produced by Producer as 2000 in this case. You can change the number to any other integer value.

After building the GET query, hit the blue `Send` button on the top right. If everything goes fine, you should receive a `200 OK` as status code.

![postman success](/images/postman-success.png)

The Producer will produce 2000 messages on the queue named `hello`. The consumer is configured to process `10` messages in a batch. The consumer also simulates a long running process by sleeping for `2 seconds`.

### 2.11 Auto-scaling in action

See the number of containers for consumer grow to adjust the messages and also the drop when messages are processed.

![autoscaling consumers](/images/pods-and-deployments-autoscaled.png)

On the left hand side of the screen you can see the pods auto scaled and on the right we see the deploymnets autoscaled progressively to 2,4,8, 16 and 30.

While the messages are being processed, we can also observe the RabbitMQ management UI.

![autoscaling consumers](/images/RabbitMQ-managementUI.PNG)

Our consumer processes 50 messages in a batch by prefetching them together. This can be verified by looking at the details of the consumers.

![Prefetch messages](/images/rabbitMQ-prefetch.PNG)

Once all the messages are processed, KEDA will scale down the pods and the deployments.

![autoscaled down consumers](/images/pods-and-deployments-scaled-down.png)

List Custom Resource Definition

```code

kubeclt get crd

```

![autoscaled down consumers](/images/KEDA-CRD.PNG)

---

As part of the KEDA installation, ScaledObject and TriggerAuthentications are deployed on the Kubernetes cluster.

## YouTube videos

As part of my YouTube channel, I also did a multi-part series on this project. The videos published on the channel are available below :

- Part 1 - Autoscaling containers with KEDA - Provision AKS cluster

[![Part 1 - Autoscaling containers with KEDA - Provision AKS cluster](/images/part1-AKS-cluster-provision.gif)](https://youtu.be/Bq2CpEcRtPw)

- Part 2 - Autoscaling containers with KEDA - Deploy Application Containers

[![Part 2 - Autoscaling containers with KEDA - Deploy Application Containers](/images/part2-apps-deployment.png)](https://youtu.be/X8x_FdN1Fvo)

- Part 3 - Autoscaling containers with KEDA - KEDA Autoscale in action

[![Part 3 - Autoscaling containers with KEDA - KEDA Autoscale in action](/images/part3-KEDA-install.gif)](https://youtu.be/X8x_FdN1Fvo)

## Slides

Here are the links to slides from the presentation

### Slideshare

[![Scaling containers with KEDA](/images/slideshare.PNG)](https://www.slideshare.net/nileshgule/scaling-containers-with-keda)

### Speakerdeck

[![Scaling containers with KEDA](/images/speakerdeck.PNG)](https://speakerdeck.com/nileshgule/scaling-containers-with-keda)

## Different talks where this repo is used

- [![Azure Singapore - Monitor Kubernetes cluster using Prometheus and Grafana - 19 August 2021](/images/azure-singapore-19-august-2021.PNG)](https://youtu.be/t8uenUoI4Mw)

- [![Microsoft Reactor Bengaluru - Monitor Kubernetes cluster using open source tools Prometheus and Grafana - 14 August 2021](/images/msreactor-bengaluru-14-Aug-2021.jpg)](https://youtu.be/Lv0D3fdwJhU)

- [![Pune User Group - How to manage event driven workloads on Kubernetes using KEDA - 27 February 2021](/images/pune-user-group-27-Feb-2021.png)](https://youtu.be/a1pkrCUuKD0)

- [![OSS Days - Serverless Event Driven Containers with KEDA - 30 October 2020](/images/oss-days-30-october-2020.jfif)](https://youtu.be/-bAlWBbRtEw?t=11049)

- [![OSS Days - Serverless Event Driven Containers with KEDA - Edureca - 30 October 2020](/images/oss-days-edureca-30-october-2020.PNG)](https://youtu.be/a_gqfKXK874?t=11141)


