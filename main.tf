provider "kubernetes" {
  config_path = var.k0s_api_config_path
  insecure    = true
}

provider "helm" {
  kubernetes {
    config_path = var.k0s_api_config_path
    insecure    = true
  }
}

locals {
  bot_configs = fileset("./config", "bot*.yaml")
}

module "yaml_config" {
  for_each                   = local.bot_configs
  source                     = "cloudposse/config/yaml"
  enabled                    = true
  map_config_local_base_path = "./config"
  map_config_paths = [
    each.key
  ]

  context = module.this.context
}

locals {
  bot_final_configs = {
    for k, v in module.yaml_config : try(v.map_configs["deployment_name"], split(".", k)[0]) => v.map_configs if try(v.map_configs["deployment_enabled"], true) != false
  }
}

output "bot_final_configs" {
  value = local.bot_final_configs
}

resource "kubernetes_namespace" "bots" {
  metadata {
    name = var.bot_namespace
  }
}

resource "helm_release" "binance_proxy" {
  name              = "binance-proxy"
  namespace         = kubernetes_namespace.bots.id
  repository        = "https://nightshift2k.github.io/helm-charts"
  chart             = "binance-proxy"
  wait              = true
  dependency_update = true
}

resource "helm_release" "bots" {
  for_each = local.bot_final_configs
  name     = tostring(each.key)
  depends_on = [
    helm_release.binance_proxy
  ]
  namespace         = kubernetes_namespace.bots.id
  repository        = "https://nightshift2k.github.io/helm-charts"
  chart             = "freqtrade"
  wait              = true
  dependency_update = true
  values            = [yamlencode(each.value)]
}
