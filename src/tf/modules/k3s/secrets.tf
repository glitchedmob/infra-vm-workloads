module "ssh_key" {
  source               = "git::https://github.com/glitchedmob/infra-shared.git//src/tf/modules/ssh-key?ref=main"
  name                 = "infra-vm-workloads"
  key_version          = 1
  ssm_private_key_path = "${local.ssm_key_prefix}/ssh-private-key"
}

module "git_deploy_key" {
  source               = "git::https://github.com/glitchedmob/infra-shared.git//src/tf/modules/ssh-key?ref=main"
  name                 = "infra-vm-workloads"
  key_version          = 1
  ssm_private_key_path = "${local.ssm_key_prefix}/git-deploy-private-key"
  ssm_public_key_path  = "${local.ssm_key_prefix}/git-deploy-public-key"
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
