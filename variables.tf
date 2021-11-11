variable "k0s_api_host" {
  description = "Host IP?"
  type        = string
}

variable "k0s_api_config_path" {
  description = "k0sctl/kubeconfig for controller "
  type        = string
  default     = "admin-default.conf"
}

variable "bot_namespace" {
  description = "kubernetes_namespace"
  type        = string
  default     = "default"
}

