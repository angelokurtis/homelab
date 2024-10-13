terraform {
  required_providers {
    proxmox = { source = "telmate/proxmox", version = "3.0.1-rc4" }
  }
}

provider "proxmox" {
  pm_api_url  = "https://192.168.68.118:8006/api2/json"
  pm_user     = var.proxmox_user
  pm_password = var.proxmox_password
}
