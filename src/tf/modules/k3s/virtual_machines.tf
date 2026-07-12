module "k3s_data_owner" {
  for_each = local.k3s_vms

  source = "git::https://github.com/glitchedmob/infra-shared.git//src/tf/modules/proxmox-data-owner?ref=main"

  name         = "${each.key}-data"
  description  = "Persistent data disk owner for ${each.key}"
  tags         = ["tf", "lz", "k3s", "data-owner"]
  node_name    = each.value.node_name
  pool_id      = local.proxmox_pool_id
  datastore_id = "vmdata"
  disk_size_gb = 200
  disk_serial  = "${each.key}-data"
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

  cpu_cores    = 4
  cpu_type     = each.value.cpu_type
  memory_mb    = each.value.memory_mb
  disk_size_gb = 80
  data_disks = {
    scsi1 = module.k3s_data_owner[each.key].disk
  }
  network_bridge = local.vm_network_bridge
  network_cidr   = local.lz_cidr
  ipv4_address   = each.value.ipv4_address
  vm_user        = local.vm_user

  ssh_public_keys = [trimspace(module.ssh_key.public_key)]

  enable_guest_agent = true
}
