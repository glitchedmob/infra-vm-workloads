locals {
  cloudflare_tunnel_token_ssm_path = "/vm-workloads/lz/infra-vm-workloads/cloudflare-tunnel-token"
  # Increment to recreate the tunnel and publish its new token to SSM.
  cloudflare_tunnel_token_version = 1
}

resource "terraform_data" "cloudflare_tunnel_token_version" {
  triggers_replace = local.cloudflare_tunnel_token_version
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "lz_k3s" {
  account_id = var.cloudflare_account_id
  name       = "lz-infra-k8s-apps"
  config_src = "cloudflare"

  lifecycle {
    replace_triggered_by = [terraform_data.cloudflare_tunnel_token_version]
  }
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "lz_k3s" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.lz_k3s.id
  source     = "cloudflare"

  config = {
    ingress = [
      {
        hostname = "*.levizitting.com"
        path     = "^/\\.well-known/acme-challenge/.*"
        service  = "http://traefik.kube-system.svc.cluster.local:80"
      },
      {
        hostname = "*.levizitting.com"
        service  = "https://traefik.kube-system.svc.cluster.local:443"
        origin_request = {
          match_sn_ito_host = true
        }
      },
      {
        service = "http_status:404"
      },
    ]
  }
}

data "cloudflare_zero_trust_tunnel_cloudflared_token" "lz_k3s" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.lz_k3s.id
}

resource "aws_ssm_parameter" "cloudflare_tunnel_token" {
  name             = local.cloudflare_tunnel_token_ssm_path
  type             = "SecureString"
  value_wo         = data.cloudflare_zero_trust_tunnel_cloudflared_token.lz_k3s.token
  value_wo_version = local.cloudflare_tunnel_token_version
}
