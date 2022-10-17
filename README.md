# README
## QUICKSTART

deploy:
`terraform apply`

### connect to k8s cluster

use `./admin-default.conf`, everything is written in there after successfull deploy

k8s status tools:
- `k9s` - TUI
- "Lens" - GUI

## TODOS

- [  ] add new nodes to local .ssh/known_hosts:
  - => [[https://docs.ansible.com/ansible/latest/collections/ansible/builtin/known_hosts_module.html]]

## FIXES

- whitelist `api.segement.io` if using adblock, pi-hole, etc
- ssh handshake error: add cluster and worker to ~/.ssh/known_hosts
  - either by connectin manually: `ssh -i ./.ssh/ft-cluster_rsa $IP`
  - or using something like `ssh-keyscan -H $IP >> ~/.ssh/known_hosts` (should probably be automated)

- authentication not working for frogtrade or ftui

e.g. 
```shell
└> curl  $node_ip:$node_port/api/v1/version
{"detail":"Unauthorized"}⏎
```

- authentication is set via ENV and not via the usual config.json stuff.
  - everything under `api_server` regarding secret used in ./helm-charts/charts/freqtrade/values.yaml is not used in deployed server
  - need to overrid `auth:` at ./config/_global_ftapi.yaml  
