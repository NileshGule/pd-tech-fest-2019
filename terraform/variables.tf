variable "client_id" {}
variable "client_secret" {}

variable "cluster_name" {
    type        = string
    description = "The cluster name." 
    default     = "demo"
}

variable "location" {
    type        = string
    description = "The Azure location to use." 
    default     = "southeastasia"
}

variable "node_count" {
    type        = number
    description = "The number of nodes to bootstrap" 
    default     = 1
}

variable "vm_size" {
    type        = string
    description = "The vm size to use" 
    default     = "Standard_D1_v2"
}

variable "vm_os" {
    type        = string
    description = "The operating system of the node" 
    default     = "Linux"
}

variable "vm_disk_size" {
    type        = number
    description = "The disk size of the node in GB" 
    default     = 50
}

variable "kubernetes_version" {
    type        = string
    description = "The disk size of the node in GB" 
    default     = "1.16.7"
}

variable "ssh_public_key" {
    default = "~/.ssh/id_rsa.pub"
}