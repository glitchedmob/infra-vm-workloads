output "workload_vm_ids" {
  value = module.lz_k3s_cluster.workload_vm_ids
}

output "git_deploy_public_key" {
  value = module.lz_k3s_cluster.git_deploy_public_key
}

output "ssm_paths" {
  value = merge(module.lz_k3s_cluster.ssm_paths, {
    cloudflare_tunnel_token = aws_ssm_parameter.cloudflare_tunnel_token.name
  })
}

output "cloudflare_tunnel_target" {
  description = "DNS target for public hostnames routed through the workload cluster tunnel"
  value       = "${cloudflare_zero_trust_tunnel_cloudflared.lz_k3s.id}.cfargotunnel.com"
}

output "lz_k3s_external_secrets_workload_role_arn" {
  description = "IAM role ARN used by External Secrets to read LZ K3s SSM parameters."
  value       = aws_iam_role.external_secrets.arn
}

output "lz_k3s_openbao_workload_role_arn" {
  description = "IAM role ARN used by OpenBao bootstrap to read its SSM parameters."
  value       = aws_iam_role.openbao.arn
}
