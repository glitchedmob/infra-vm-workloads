data "cloudflare_accounts" "current" {
  max_items = 2
}

locals {
  cloudflare_account_id               = one(data.cloudflare_accounts.current.result).id
  cloudflare_tunnel_token_ssm_path    = "/vm-workloads/lz/infra-vm-workloads/cloudflare-tunnel-token"
  cloudflare_tunnel_token_ssm_version = 1
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "lz_k3s" {
  account_id = local.cloudflare_account_id
  name       = "lz-infra-k8s-apps"
  config_src = "cloudflare"
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "lz_k3s" {
  account_id = local.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.lz_k3s.id
  source     = "cloudflare"

  config = {
    ingress = [
      {
        hostname = "*.levizitting.com"
        path     = "^/\\.well-known/acme-challenge/.*"
        service  = "http://127.0.0.1:8000"
      },
      {
        hostname = "*.levizitting.com"
        service  = "https://127.0.0.1:8443"
        origin_request = {
          http2_origin       = true
          origin_server_name = "traefik.levizitting.com"
          ca_pool            = "/etc/cloudflared/origin-ca/ca.crt"
        }
      },
      {
        service = "http_status:404"
      },
    ]
  }
}

data "cloudflare_zero_trust_tunnel_cloudflared_token" "lz_k3s" {
  account_id = local.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.lz_k3s.id
}

resource "aws_ssm_parameter" "cloudflare_tunnel_token" {
  name             = local.cloudflare_tunnel_token_ssm_path
  type             = "SecureString"
  value_wo         = data.cloudflare_zero_trust_tunnel_cloudflared_token.lz_k3s.token
  value_wo_version = local.cloudflare_tunnel_token_ssm_version
}
