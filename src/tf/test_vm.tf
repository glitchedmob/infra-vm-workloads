locals {
  test_vm = {
    name         = "lz-test-01"
    node_name    = "x86-node-01"
    ipv4_address = "10.20.0.12"
  }
}

module "test_vm" {
  source = "git::https://github.com/glitchedmob/infra-shared.git//src/tf/modules/proxmox-vm?ref=main"

  name        = local.test_vm.name
  description = "Managed by OpenTofu for lz test VM demos"
  tags        = ["tf", "lz", "test"]
  node_name   = local.test_vm.node_name
  pool_id     = local.proxmox_pool_id
  os_id       = "debian13"

  cpu_cores      = 2
  memory_mb      = 4096
  disk_size_gb   = 40
  network_bridge = local.vm_network_bridge
  network_cidr   = local.lz_cidr
  ipv4_address   = local.test_vm.ipv4_address
  vm_user        = local.vm_user

  ssh_public_keys = [trimspace(module.ssh_key.public_key)]

  enable_guest_agent = true
}
