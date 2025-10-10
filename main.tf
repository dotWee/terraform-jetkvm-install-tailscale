module "tailscale_jetkvm" {
  source = "./modules/tailscale-jetkvm"

  device_ip            = var.device_ip
  ssh_user             = var.ssh_user
  ssh_private_key_file = var.ssh_private_key_file

  tailscale_version    = var.tailscale_version
  tailscale_arch       = var.tailscale_arch
  tailscale_state_dir  = var.tailscale_state_dir
  tailscale_dir        = var.tailscale_dir
  tailscale_auth_key   = var.tailscale_auth_key
  tailscale_extra_args = var.tailscale_extra_args
  nftables_mode        = var.nftables_mode
  tailscale_hostname   = var.tailscale_hostname
}
