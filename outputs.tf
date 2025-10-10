output "device_ip" {
  description = "JetKVM device IP."
  value       = var.device_ip
}

output "tailscale_dir" {
  description = "Directory on device where tailscale binaries are placed."
  value       = var.tailscale_dir
}

output "tailscale_state_dir" {
  description = "Directory on device where tailscale state is stored."
  value       = var.tailscale_state_dir
}


