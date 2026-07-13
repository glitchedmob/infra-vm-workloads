output "workload_vm_ids" {
  value = {
    for name, vm in module.k3s_vm :
    name => vm.vm_id
  }
}

output "git_deploy_public_key" {
  value = module.git_deploy_key.public_key
}

output "ssm_paths" {
  value = {
    ssh_private_key                       = module.ssh_key.ssm_path
    git_deploy_private_key                = module.git_deploy_key.ssm_path
    git_deploy_public_key                 = module.git_deploy_key.ssm_public_key_path
    openbao_unseal_key                    = aws_ssm_parameter.openbao_unseal_key.name
    dex_github_oauth_client_secret        = aws_ssm_parameter.dex_github_oauth_client_secret.name
    dex_client_secrets                    = aws_ssm_parameter.dex_client_secrets.name
    oauth2_proxy_cookie_secret            = aws_ssm_parameter.oauth2_proxy_cookie_secret.name
    seaweedfs_s3_admin_access_key         = aws_ssm_parameter.seaweedfs_s3_admin_access_key.name
    seaweedfs_s3_admin_secret_key         = aws_ssm_parameter.seaweedfs_s3_admin_secret_key.name
    seaweedfs_s3_observability_access_key = aws_ssm_parameter.seaweedfs_s3_observability_access_key.name
    seaweedfs_s3_observability_secret_key = aws_ssm_parameter.seaweedfs_s3_observability_secret_key.name
  }
}
