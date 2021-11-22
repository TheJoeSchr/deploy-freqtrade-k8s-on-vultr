variable "ssh_key_path" {
  description = "Path to ssh key used to connect to nodes"
  type        = string
}

variable "deployment_vultr_api_key" {
  description = "Vultr API Key for the Terraform deployment"
  type        = string
  sensitive   = true
}

variable "cluster_vultr_api_key" {
  description = "Vultr API Key for the Terraform deployment (deploy cluster)"
  type        = string
  sensitive   = true
}

variable "bot_namespace" {
  description = "kubernetes_namespace"
  type        = string
  default     = "default"
}

