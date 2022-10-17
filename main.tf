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
  worker_count = length(local.bot_final_configs)
}

data "local_file" "ssh_key" {
  filename = var.ssh_key_path
}

module "condor" {
  source                            = "./terraform-vultr-condor"
  cluster_name                      = var.bot_namespace
  deployment_vultr_api_key          = var.deployment_vultr_api_key
  cluster_vultr_api_key             = var.deployment_vultr_api_key
  worker_count                      = local.worker_count
  region                            = "nrt"
  cluster_os                        = "Debian 10 x64 (buster)"
  worker_plan                       = "vhf-1c-1gb"
  controller_plan                   = "vc2-1c-1gb"
  cluster_append_random_id          = false
  cluster_external_dns_domain       = "a-domain-that-exists-in-your-vultr-account.xyz"
  cluster_create_external_dns_hosts = false
  enable_vultr_csi                  = false
  # disable components (valid items: konnectivity-server,kube-scheduler,kube-controller-manager,control-api,csr-approver,default-psp,kube-proxy,coredns,network-provider,helm,metrics-server,kubelet-config,system-rbac)
  k0s_disable_components = [
    "metrics-server"
  ]
  control_plane_firewall_rules = [
    {
      port    = 6443
      ip_type = "v4"
      source  = "0.0.0.0/0"
    },
    {
      port    = 80
      ip_type = "v4"
      source  = "0.0.0.0/0"
    }
  ]
}

resource "kubernetes_namespace" "bots" {
  metadata {
    name = var.bot_namespace
  }
}

locals {
  k0s_api_config_path = module.condor.kubeconfig
}
provider "kubernetes" {
  config_path = local.k0s_api_config_path
  insecure    = true
}

provider "helm" {
  kubernetes {
    config_path = local.k0s_api_config_path
    insecure    = true
  }
}

resource "helm_release" "bots" {
  for_each = local.bot_final_configs
  name     = tostring(each.key)
  depends_on = [
    module.condor
  ]
  namespace         = kubernetes_namespace.bots.id
  /* repository        = "https://nightshift2k.github.io/helm-charts" */
  /* chart             = "freqtrade" */
  chart             = "./helm-charts/charts/freqtrade"
  wait              = true
  dependency_update = true
  values            = [yamlencode(each.value)]
}

# generate frogtrade-9000 config yaml
resource "local_file" "ft9000-config" {
  content = templatefile("${path.module}/templates/ft9000-servers.tpl",
  {
    instances = zipmap(
        flatten([ for o in helm_release.bots : o.name ]),
        flatten(tolist(
            module.condor.worker_ips,
        )),
    )
    usernames = zipmap(
        flatten([ for o in helm_release.bots : o.name ]),
        flatten([ for o in helm_release.bots : local.bot_final_configs[o.name].auth.api.username] )
    )
    passwords = zipmap(
        flatten([ for o in helm_release.bots : o.name ]),
        flatten([ for o in helm_release.bots : local.bot_final_configs[o.name].auth.api.password] )
    )
    port = "30000"
  })
  filename = "${abspath(path.root)}/output/ft9000-servers.yaml"
  file_permission = "0600"
}
