output "workload_vm_ids" {
  description = "Proxmox VM IDs for workload instances"
  value = {
    for name, vm in module.k3s_vm :
    name => vm.vm_id
  }
}

output "ssh_private_key_ssm_path" {
  description = "SSM path for generated workload SSH private key"
  value       = module.ssh_key.ssm_path
}

output "git_deploy_private_key_ssm_path" {
  description = "SSM path for Git deploy private key"
  value       = module.git_deploy_key.ssm_path
}

output "git_deploy_public_key" {
  description = "Git deploy public key to add as repository deploy key"
  value       = module.git_deploy_key.public_key
}

output "git_deploy_public_key_ssm_path" {
  description = "SSM path for Git deploy public key"
  value       = module.git_deploy_key.ssm_public_key_path
}

output "argocd_github_oauth_client_id_ssm_path" {
  description = "SSM path for Argo CD GitHub OAuth client ID"
  value       = aws_ssm_parameter.argocd_github_oauth_client_id.name
}

output "argocd_github_oauth_client_secret_ssm_path" {
  description = "SSM path for Argo CD GitHub OAuth client secret"
  value       = aws_ssm_parameter.argocd_github_oauth_client_secret.name
}
