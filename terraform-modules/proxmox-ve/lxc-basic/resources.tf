terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.10"
    }
  }
}

provider "proxmox" {
  pm_api_url      = "https://${var.proxmox_host}:8006/api2/json"
  pm_user         = var.pm_user
  pm_tls_insecure = true
}

resource "proxmox_lxc" "container" {
  target_node = var.node_name

  hostname = var.container_hostname
  vmid     = var.container_id

  ostemplate   = var.container_os_template
  password     = var.container_password
  unprivileged = var.container_unprivileged
  start        = var.container_start_after_creation

  cores  = var.container_cpu_cores
  memory = var.container_memory
  swap   = var.container_swap

  features {
    fuse    = true
    nesting = true
    mount   = "cifs;nfs"
  }

  rootfs {
    size    = var.container_boot_disk_size
    storage = var.container_boot_disk_storage_pool
  }

  # if you want two NICs, just copy this whole network section and duplicate it
  network {
    name     = var.container_network_interface
    bridge   = var.container_network_bridge
    ip       = var.container_network_ip
    gw       = var.container_network_gateway
    tag      = var.container_network_tag
    firewall = true
  }

  nameserver = var.container_network_dns

  ssh_public_keys = <<EOF
  ${var.ssh_public_keys}
  EOF
}
