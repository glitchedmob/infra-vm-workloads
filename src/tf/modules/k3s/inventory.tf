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
    data_disk_serial                            = module.k3s_data_owner[each.key].disk.serial
    proxmox_vm_role                             = each.value.role
    ansible_ssh_use_ssh_agent                   = "false"
  }
}
