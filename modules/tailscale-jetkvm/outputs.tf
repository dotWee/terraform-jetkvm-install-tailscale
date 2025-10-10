output "device_ip" {
  value       = var.device_ip
  description = "JetKVM device IP"
}

output "tailscale_dir" {
  value       = var.tailscale_dir
  description = "Directory where tailscale binaries are installed"
}

output "tailscale_state_dir" {
  value       = var.tailscale_state_dir
  description = "Directory where tailscale state is stored"
}


