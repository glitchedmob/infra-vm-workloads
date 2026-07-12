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
      memory_mb    = 16 * 1024
      cpu_type     = "x86-64-v3"
    }
    lz-k3s-02 = {
      node_name    = "x86-node-02"
      ipv4_address = "10.20.0.11"
      role         = "server"
      memory_mb    = 14 * 1024
      cpu_type     = "x86-64-v3"
    }
    lz-k3s-03 = {
      node_name    = "x86-node-01"
      ipv4_address = "10.20.0.12"
      role         = "server"
      memory_mb    = 16 * 1024
      cpu_type     = "x86-64-v2-AES"
    }
  }
}
