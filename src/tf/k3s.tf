locals {
  proxmox_pool_id   = "lz"
  lz_cidr           = "10.20.0.0/22"
  vm_network_bridge = "lz"
  vm_user           = "admin"

  ssm_key_prefix = "/vm-workloads/lz/infra-vm-workloads"

  ssm_eso_access_key_id_path     = "/homelab/lz-vms/eso-ssm-access-key-id"
  ssm_eso_secret_access_key_path = "/homelab/lz-vms/eso-ssm-secret-access-key"

  k3s_vms = {
    lz-k3s-01 = {
      node_name    = "x86-node-01"
      ipv4_address = "10.20.0.10"
      role         = "server"
      memory_mb    = 16384
      cpu_type     = "x86-64-v3"
    }
    lz-k3s-02 = {
      node_name    = "x86-node-02"
      ipv4_address = "10.20.0.11"
      role         = "server"
      memory_mb    = 12288
      cpu_type     = "x86-64-v3"
    }
    lz-k3s-03 = {
      node_name    = "x86-node-01"
      ipv4_address = "10.20.0.12"
      role         = "server"
      memory_mb    = 16384
      cpu_type     = "x86-64-v3"
    }
  }
}

ephemeral "random_bytes" "openbao_unseal" {
  length = 32
}

resource "aws_ssm_parameter" "openbao_unseal_key" {
  name             = "${local.ssm_key_prefix}/openbao-unseal-key"
  type             = "SecureString"
  value_wo         = ephemeral.random_bytes.openbao_unseal.base64
  value_wo_version = 1
}

module "ssh_key" {
  source               = "git::https://github.com/glitchedmob/infra-shared.git//src/tf/modules/ssh-key?ref=main"
  name                 = "infra-vm-workloads"
  key_version          = 1
  ssm_private_key_path = "${local.ssm_key_prefix}/ssh-private-key"
}

module "k3s_vm" {
  for_each = local.k3s_vms

  source = "git::https://github.com/glitchedmob/infra-shared.git//src/tf/modules/proxmox-vm?ref=main"

  name        = each.key
  description = "Managed by OpenTofu for lz workload cluster"
  tags        = ["tf", "lz", "k3s"]
  node_name   = each.value.node_name
  pool_id     = local.proxmox_pool_id
  os_id       = "debian13"

  cpu_cores      = 4
  cpu_type       = each.value.cpu_type
  memory_mb      = each.value.memory_mb
  disk_size_gb   = 80
  network_bridge = local.vm_network_bridge
  network_cidr   = local.lz_cidr
  ipv4_address   = each.value.ipv4_address
  vm_user        = local.vm_user

  ssh_public_keys = [trimspace(module.ssh_key.public_key)]

  enable_guest_agent = true
}

module "git_deploy_key" {
  source               = "git::https://github.com/glitchedmob/infra-shared.git//src/tf/modules/ssh-key?ref=main"
  name                 = "infra-vm-workloads"
  key_version          = 1
  ssm_private_key_path = "${local.ssm_key_prefix}/git-deploy-private-key"
  ssm_public_key_path  = "${local.ssm_key_prefix}/git-deploy-public-key"
}



resource "aws_ssm_parameter" "argocd_github_oauth_client_secret" {
  name             = "${local.ssm_key_prefix}/argocd-github-oauth-client-secret"
  type             = "SecureString"
  value_wo         = "CHANGEME"
  value_wo_version = 1
}

resource "aws_ssm_parameter" "grafana_github_oauth_client_secret" {
  name             = "${local.ssm_key_prefix}/grafana-github-oauth-client-secret"
  type             = "SecureString"
  value_wo         = "CHANGEME"
  value_wo_version = 1
}

resource "aws_ssm_parameter" "dex_github_oauth_client_secret" {
  name             = "${local.ssm_key_prefix}/dex-github-oauth-client-secret"
  type             = "SecureString"
  value_wo         = "CHANGEME"
  value_wo_version = 1
}

ephemeral "random_password" "dex_client_argocd" {
  length  = 40
  special = false
}

ephemeral "random_password" "dex_client_grafana" {
  length  = 40
  special = false
}

ephemeral "random_password" "dex_client_oauth2_proxy" {
  length  = 40
  special = false
}

ephemeral "random_password" "dex_client_openbao" {
  length  = 40
  special = false
}

ephemeral "random_password" "oauth2_proxy_cookie" {
  length  = 32
  special = false
}

resource "aws_ssm_parameter" "dex_client_secrets" {
  name = "${local.ssm_key_prefix}/dex-client-secrets"
  type = "SecureString"
  value_wo = jsonencode({
    argocdClientSecret      = ephemeral.random_password.dex_client_argocd.result
    grafanaClientSecret     = ephemeral.random_password.dex_client_grafana.result
    oauth2ProxyClientSecret = ephemeral.random_password.dex_client_oauth2_proxy.result
    openbaoClientSecret     = ephemeral.random_password.dex_client_openbao.result
  })
  value_wo_version = 1
}

resource "aws_ssm_parameter" "oauth2_proxy_cookie_secret" {
  name             = "${local.ssm_key_prefix}/oauth2-proxy-cookie-secret"
  type             = "SecureString"
  value_wo         = ephemeral.random_password.oauth2_proxy_cookie.result
  value_wo_version = 1
}

ephemeral "random_password" "seaweedfs_admin_secret_key" {
  length  = 40
  special = false
}

ephemeral "random_password" "seaweedfs_observability_secret_key" {
  length  = 40
  special = false
}

resource "aws_ssm_parameter" "seaweedfs_s3_admin_access_key" {
  name  = "${local.ssm_key_prefix}/seaweedfs-s3-admin-access-key"
  type  = "SecureString"
  value = "seaweedfs-admin"
}

resource "aws_ssm_parameter" "seaweedfs_s3_admin_secret_key" {
  name             = "${local.ssm_key_prefix}/seaweedfs-s3-admin-secret-key"
  type             = "SecureString"
  value_wo         = ephemeral.random_password.seaweedfs_admin_secret_key.result
  value_wo_version = 1
}

resource "aws_ssm_parameter" "seaweedfs_s3_observability_access_key" {
  name  = "${local.ssm_key_prefix}/seaweedfs-s3-observability-access-key"
  type  = "SecureString"
  value = "seaweedfs-observability"
}

resource "aws_ssm_parameter" "seaweedfs_s3_observability_secret_key" {
  name             = "${local.ssm_key_prefix}/seaweedfs-s3-observability-secret-key"
  type             = "SecureString"
  value_wo         = ephemeral.random_password.seaweedfs_observability_secret_key.result
  value_wo_version = 1
}

resource "ansible_group" "k3s_servers" {
  name = "k3s_servers"
}

resource "ansible_group" "k3s_x86_64_v3" {
  name     = "k3s_x86_64_v3"
  children = []
}

resource "ansible_group" "k3s_x86_64_v2" {
  name     = "k3s_x86_64_v2"
  children = []
}

resource "ansible_group" "k3s_agents" {
  name = "k3s_agents"
}

resource "ansible_group" "k3s_cluster" {
  name = "k3s_cluster"
  children = [
    ansible_group.k3s_servers.name,
    ansible_group.k3s_agents.name,
  ]
}

resource "ansible_host" "workload" {
  for_each = local.k3s_vms

  name = each.key
  groups = [
    "k3s_cluster",
    each.value.role == "server" ? "k3s_servers" : "k3s_agents",
    each.value.cpu_type == "x86-64-v2-AES" ? "k3s_x86_64_v2" : "k3s_x86_64_v3",
  ]

  variables = {
    ansible_host                                = each.value.ipv4_address
    ansible_user                                = local.vm_user
    node_name                                   = each.value.node_name
    ssm_private_key_path                        = module.ssh_key.ssm_path
    ssm_git_deploy_private_key_path             = module.git_deploy_key.ssm_path
    ssm_eso_access_key_id_path                  = local.ssm_eso_access_key_id_path
    ssm_eso_secret_access_key_path              = local.ssm_eso_secret_access_key_path
    ssm_argocd_github_oauth_client_secret_path  = aws_ssm_parameter.argocd_github_oauth_client_secret.name
    ssm_grafana_github_oauth_client_secret_path = aws_ssm_parameter.grafana_github_oauth_client_secret.name
    ssm_seaweedfs_s3_admin_access_key_path      = aws_ssm_parameter.seaweedfs_s3_admin_access_key.name
    ssm_seaweedfs_s3_admin_secret_key_path      = aws_ssm_parameter.seaweedfs_s3_admin_secret_key.name
    ssm_seaweedfs_s3_obs_access_key_path        = aws_ssm_parameter.seaweedfs_s3_observability_access_key.name
    ssm_seaweedfs_s3_obs_secret_key_path        = aws_ssm_parameter.seaweedfs_s3_observability_secret_key.name
    ssm_tailscale_authkey_path                  = "/homelab/headscale/lz-k3s/${each.key}-auth-key"
    proxmox_vm_role                             = each.value.role
    ansible_ssh_use_ssh_agent                   = "false"
  }
}
