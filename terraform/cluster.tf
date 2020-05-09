resource "azurerm_resource_group" "cluster" {
  name     = "${var.cluster_name}-kube-group"
  location = "${var.location}"
}

resource "azurerm_kubernetes_cluster" "kube_cluster" {
    name                = "${var.cluster_name}-k8s"
    location            = azurerm_resource_group.cluster.location
    resource_group_name = azurerm_resource_group.cluster.name
    dns_prefix          = "${var.cluster_name}-k8s"
    kubernetes_version  = var.kubernetes_version

    linux_profile {
        admin_username = "ubuntu"

        ssh_key {
            key_data = file(var.ssh_public_key)
        }
    }

    default_node_pool {
        name            = "default"
        node_count      = var.node_count
        vm_size         = var.vm_size
    }


  service_principal {
    client_id     = "${var.client_id}"
    client_secret = "${var.client_secret}"
  }
}