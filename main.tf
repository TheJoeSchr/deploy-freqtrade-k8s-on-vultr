data "local_file" "ssh_key" {
    filename ="/home/joe/.ssh/id_rsa_github.pub"
}

module "condor" {
    source = "./terraform-vultr-condor"
    deployment_vultr_api_key = "N675KKYIKHOXZTWZ46Z23VHJH6FWEYG3BQKA"
    cluster_vultr_api_key = "N675KKYIKHOXZTWZ46Z23VHJH6FWEYG3BQKA"
    region = "nrt"
    cluster_name = "frq-test"
    cluster_os = "Debian 10 x64 (buster)"
    worker_plan = "vc2-1c-1gb"
    controller_plan = "vc2-1c-1gb"
    worker_count = 2
    cluster_append_random_id = false
    cluster_external_dns_domain = "a-domain-that-exists-in-your-vultr-account.xyz"
    cluster_create_external_dns_hosts = false
    enable_vultr_csi = false
    # disable components (valid items: konnectivity-server,kube-scheduler,kube-controller-manager,control-api,csr-approver,default-psp,kube-proxy,coredns,network-provider,helm,metrics-server,kubelet-config,system-rbac)
    k0s_disable_components = [
        "metrics-server"
    ]
    control_plane_firewall_rules = [
        {
            port    = 6443
            ip_type = "v4"
            source  = "0.0.0.0/0"
        }
    ]
}