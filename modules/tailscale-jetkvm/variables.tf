variable "device_ip" {
  type        = string
  description = "IP address of the JetKVM device"
}

variable "ssh_user" {
  type        = string
  description = "SSH user to connect to JetKVM"
  default     = "root"
}

variable "ssh_private_key_file" {
  type        = string
  description = "Path to SSH private key file"
}

variable "tailscale_version" {
  type        = string
  description = "Tailscale version to install"
}

variable "tailscale_arch" {
  type        = string
  description = "Tailscale architecture to install (arm for JetKVM)"
  default     = "arm"
}

variable "tailscale_state_dir" {
  type        = string
  description = "Path to Tailscale state directory on device"
  default     = "/userdata/tailscale-state"
}

variable "tailscale_dir" {
  type        = string
  description = "Directory to install Tailscale binaries on device"
  default     = "/userdata/tailscale"
}

variable "tailscale_auth_key" {
  type        = string
  description = "Tailscale auth key; if null, interactive login is used"
  default     = null
  sensitive   = true
}

variable "tailscale_extra_args" {
  type        = string
  description = "Additional flags for 'tailscale up'"
  default     = ""
}

variable "nftables_mode" {
  type        = bool
  description = "Enable nftables firewall mode"
  default     = true
}

variable "tailscale_hostname" {
  type        = string
  description = "Hostname to set for the Tailscale node"
  default     = "jetkvm"
}


