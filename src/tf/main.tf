module "lz_k3s_cluster" {
  source = "./modules/k3s"
}

moved {
  from = module.k3s
  to   = module.lz_k3s_cluster
}
