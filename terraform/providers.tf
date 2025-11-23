terraform {
  required_version = ">= 1.9"

  required_providers {
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.38" }
    talos      = { source = "siderolabs/talos", version = "~> 0.9" }
  }
}

locals {
  talos_config = yamldecode(file(pathexpand("~/.talos/config")))
  talos_ctx    = local.talos_config["contexts"]["homelab-talos-dev"]

  talos_client_config = {
    ca_certificate     = local.talos_ctx["ca"]
    client_certificate = local.talos_ctx["crt"]
    client_key         = local.talos_ctx["key"]
  }
}
# This resource is equivalent to running the following talosctl command manually:
# talosctl kubeconfig --talosconfig ~/.talos/config --context <your-context> --nodes <node-ip>
#
# It automatically retrieves the Kubernetes kubeconfig from the Talos control plane node,
# using credentials and endpoints specified in your local Talos config.
resource "talos_cluster_kubeconfig" "default" {
  client_configuration = local.talos_client_config
  node                 = local.talos_ctx["endpoints"][0]
}

provider "kubernetes" {
  host                   = yamldecode(talos_cluster_kubeconfig.default.kubeconfig_raw)["clusters"][0]["cluster"]["server"]
  client_certificate     = base64decode(yamldecode(talos_cluster_kubeconfig.default.kubeconfig_raw)["users"][0]["user"]["client-certificate-data"])
  client_key             = base64decode(yamldecode(talos_cluster_kubeconfig.default.kubeconfig_raw)["users"][0]["user"]["client-key-data"])
  cluster_ca_certificate = base64decode(yamldecode(talos_cluster_kubeconfig.default.kubeconfig_raw)["clusters"][0]["cluster"]["certificate-authority-data"])
}
