variable "device_ip" {
  description = "IP address of the JetKVM device (e.g., 10.10.0.6)."
  type        = string
}

variable "ssh_user" {
  description = "SSH user for JetKVM (developer mode)."
  type        = string
  default     = "root"
}

variable "ssh_private_key_file" {
  description = "Path to the SSH private key file used to authenticate to JetKVM."
  type        = string
}

variable "tailscale_version" {
  description = "Tailscale version to install (e.g., 1.88.3)."
  type        = string
  default     = "1.88.3"
}

variable "tailscale_arch" {
  description = "Tailscale architecture (arm for JetKVM / ARMv7)."
  type        = string
  default     = "arm"
}

variable "tailscale_state_dir" {
  description = "Directory to store Tailscale state on device."
  type        = string
  default     = "/userdata/tailscale-state"
}

variable "tailscale_dir" {
  description = "Directory on device where tailscale binaries are placed."
  type        = string
  default     = "/userdata/tailscale"
}

variable "tailscale_auth_key" {
  description = "Tailscale auth key. If null, interactive login is used."
  type        = string
  default     = null
  sensitive   = true
}

variable "tailscale_extra_args" {
  description = "Additional flags for 'tailscale up' (e.g., --advertise-tags=tag:jetkvm)."
  type        = string
  default     = ""
}

variable "nftables_mode" {
  description = "Enable nftables firewall mode (required on BusyBox without iptables)."
  type        = bool
  default     = true
}

variable "tailscale_hostname" {
  description = "Hostname to set for the Tailscale node."
  type        = string
  default     = "jetkvm"
}


