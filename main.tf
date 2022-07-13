provider "kubernetes" {
  cluster_ca_certificate = var.cluster_ca_certificate
  host                   = var.cluster_host
  token                  = var.cluster_token
}

provider "kubectl" {
  cluster_ca_certificate = var.cluster_ca_certificate
  host                   = var.cluster_host
  token                  = var.cluster_token
  load_config_file       = false
}

provider "flux" {}
