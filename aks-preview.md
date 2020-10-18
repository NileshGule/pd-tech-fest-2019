# AKS Preview features

## Start Stop cluster

## containerd runtime

### enable preview features

Install `aks-preview` Azure CLI extension

```code

az extension add --name aks-preview

```

Register the `UseCustomizedContainerRuntime` feature

```code

az feature register --name UseCustomizedContainerRuntime --namespace Microsoft.ContainerService

```

Register the `UseCustomizedUbuntuPreview` feature

```code

az feature register --name UseCustomizedUbuntuPreview --namespace Microsoft.ContainerService

```

### Check the registration status

```code

az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService/UseCustomizedContainerRuntime')].{Name:name,State:properties.state}"

az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService/UseCustomizedUbuntuPreview')].{Name:name,State:properties.state}"

```

### Refresh registration of `Microsoft.ContainerService` resource provider

```code

az provider register --namespace Microsoft.ContainerService

```

### use `containerd` as container runtime when cluster is created

Add the following lines to the cluster creation command

`--aks-custom-headers CustomizedUbuntu=aks-ubuntu-1804,ContainerRuntime=containerd`
