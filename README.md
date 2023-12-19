# Docker Prod

> **⚠️ Warning**
>
> These are config examples and should be used at your own risk.

## APT-cacher-ng
1. `docker context use docker-prod`
1. `docker build -f docker/Dockerfile-cacher -t apt-cacher-ng-ubuntu .`
1. `cat conf/apt-cache-ng/acng.conf| docker config create apt-cache-ng-config -`
1. `docker stack deploy -c docker-compose-swarm-cacher.yml cacher`
1. `docker service logs -f cacher_apt-cacher-ng`

## Squid
1. `docker context use docker-prod`
1. `docker build -f docker/Dockerfile-squid -t squid-alpine .`
1. `cat conf/squid/squid.conf | docker config create squid-config -`
1. `docker stack deploy -c docker-compose-swarm-squid.yml squid`
1. `docker service logs -f squid_squid`

## Treafik
1. `docker context use docker-prod`
1. `cat conf/traefik/dyn-v3.yaml|  docker config create traefik-dyn -`
1. `cat conf/traefik/traefik.yml | docker config create traefik-conf -`
1. `cat conf/tls/traefik.crt| docker secret create traefik-ssl-crt -`
1. `cat conf/tls/traefik.key| docker secret create traefik-ssl-key -`
1. `docker stack deploy -c docker-compose-swarm-traefik.yml traefik`
1. `docker service logs -f traefik_traefik`

## Vault
1. `docker context use docker-prod`
1. `cat conf/vault/consul-config-swarm.hcl | docker config create vault-example-local-consul-config -`
1. `cat conf/vault/vault-config-swarm.hcl | docker config create vault-example-local-config -`
1. `cat conf/vault/ldap.ldif | docker config create vault-example-local-ldap-auth-config -`
1. `cat conf/vault/admin-user-policy.hcl | docker config create vault-example-local-ldap-admin-policy -`
1. `cat conf/vault/vault_init_setup.sh | docker config create vault-example-local-init-script -`
1. `docker stack deploy -c docker-compose-swarm-vault.yml vault`
1. Open web browser and init Vault
1. `docker exec -it $(docker ps | grep vault_vault | awk '{print $1}') /vault/vault-init-setup.sh`
    1. Enter Vault root token
    1. Enter `ldaps://freeipa.example.local` for LDAPs URL
    1. Enter `vault` for BIND username
    1. Enter `<vault BIND password>` for BIND password

## Grafana
### Alertmanager
1. `export SLACK_WEB_HOOK=<slack webhook>`
1. `export SLACK_CHANNEL=homelab`
1. `cat conf/alertmanager/alertmanager.yaml | sed "s/{{ SLACK_CHANNEL }}/${SLACK_CHANNEL}/g" | sed "s#{{ SLACK_WEB_HOOK }}#${SLACK_WEB_HOOK}#g" | docker config create alertmanager-config -`

### Prometheus

### Grafana

### Spin up stack
1. `docker stack deploy -c docker-compose-swarm-grafana.yml grafana`

## Gitlab
### Create LDAP account
1. `scp conf/gitlab/gitlab-sysaccount-ldap.ldif root@freeipa.example.local:~/gitlab-sysaccount-ldap.ldif`
1. `ldapmodify -h localhost -p 389 -x -D "cn=Directory Manager" -W -f gitlab-sysaccount.ldif`
    1. Enter directory service password

### Create secrets
1. `openssl rand -base64 32 | tr -cd '[:alnum:]' | docker secret create gitlab-postgres-gitlab-password -`
1. `openssl rand -base64 32 | tr -cd '[:alnum:]' | docker secret create gitlab-root-password -`

### Spin up stack
1. `docker stack deploy -c docker-compose-swarm-gitlab.yml gitlab`
1. `docker service logs -f gitlab_gitlab`



## idrac_exporter
1. Log into iLO
1. Administration > User Administration
1. Add a user named `metrics` with **NO** special perms
1. Add username and password to `conf/idrac_exporter`
1. Add to `conf/prometheus/prometheus.yml`
```yaml
############################### idrac_exporter ###############################
  - job_name: idrac
    static_configs:
      - targets: ['192.168.1.210']
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: idrac_exporter:9348
```


## References
### APT-cacher-ng
* [Make a Docker application write to stdout](https://serverfault.com/questions/599103/make-a-docker-application-write-to-stdout)
* [docker-apt-cacher-ng/Dockerfile](https://github.com/sameersbn/docker-apt-cacher-ng/blob/master/Dockerfile)
* [docker-apt-cacher-ng/entrypoint.sh](https://github.com/sameersbn/docker-apt-cacher-ng/blob/master/entrypoint.sh)
* []()
* []()
* []()
* []()
* []()

### Squid proxy
* []()
* []()
* []()
* []()
* []()
* []()
* []()
* []()

### Traefik
* [Recommended TLS Ciphers for Traefik](https://stackoverflow.com/questions/52128979/recommended-tls-ciphers-for-traefik)
* [traefik 2.7, intermediate config](https://ssl-config.mozilla.org/#server=traefik&version=2.7&config=intermediate&guideline=5.6)
* [Gitlab (docker) behind traefik v2](https://community.traefik.io/t/gitlab-docker-behind-traefik-v2/2268)
* [traefik](https://hub.docker.com/_/traefik?tab=tags)
* []()
* []()
* []()

### Terraform - Vault
* [Codify Management of Vault Using Terraform](https://learn.hashicorp.com/tutorials/vault/codify-mgmt-oss)
* [vault_pki_secret_backend_root_cert](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/pki_secret_backend_root_cert)
* [vault_mount](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/mount)
* [INSTALL/SETUP VAULT FOR PKI + NGINX + DOCKER – BECOMING YOUR OWN CA](https://holdmybeersecurity.com/2020/07/09/install-setup-vault-for-pki-nginx-docker-becoming-your-own-ca/)
* [vault_pki_secret_backend_cert](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/pki_secret_backend_cert)
* [vault_pki_secret_backend_intermediate_set_signed](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/pki_secret_backend_intermediate_set_signed)
* [vault_pki_secret_backend_sign](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/pki_secret_backend_sign)
* [vault_pki_secret_backend_role](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/pki_secret_backend_role#max_ttl)
* [Creating a Certificate Authority With Hashicorp Vault and Terraform](https://stvdilln.medium.com/creating-a-certificate-authority-with-hashicorp-vault-and-terraform-4d9ddad31118)
* [vault_pki_secret_backend_root_sign_intermediate](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/pki_secret_backend_root_sign_intermediate)
* []()
* []()
* []()
* []()
* []()

## Unifi + Unifipoller
* [Unifipoller - Application Configuration](https://unpoller.com/docs/install/configuration/)
* [Unifipoller - Docker Compose](https://unpoller.com/docs/install/dockercompose)
* [How To provisioning Dashboards in Grafana](https://blog.bajonczak.com/how-to-provisioning-dashboards-in-grafana/)
* [docker-compose.env.example](https://github.com/unpoller/unpoller/blob/master/init/docker/docker-compose.env.example)
* [docker-compose.yml](https://github.com/unpoller/unpoller/blob/master/init/docker/docker-compose.yml)


## idrac_exporter
* [mrlhansen/idrac_exporter](https://hub.docker.com/r/mrlhansen/idrac_exporter)
* [mrlhansen/idrac_exporter](https://github.com/mrlhansen/idrac_exporter/commits/master)
* [grafana/idrac.json](https://github.com/mrlhansen/idrac_exporter/blob/master/grafana/idrac.json)
* [grafana/idrac_overview.json](https://github.com/mrlhansen/idrac_exporter/blob/master/grafana/idrac_overview.json)
* []()
* []()
* []()
* []()
* []()
* []()

## Proxmox
* [how to assign role](https://forum.proxmox.com/threads/how-to-assign-role.33199/)
* [Dockerhub - prompve/prometheus-pve-exporter](https://hub.docker.com/r/prompve/prometheus-pve-exporter/tags)
* [prometheus-pve/prometheus-pve-exporter](https://github.com/prometheus-pve/prometheus-pve-exporter)
* []()
* []()
* []()
