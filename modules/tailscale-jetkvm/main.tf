locals {
  firewall_prefix = var.nftables_mode ? "TS_DEBUG_FIREWALL_MODE=nftables " : ""

  init_template = templatefile(
    "${path.module}/templates/init.S22tailscale.sh.tmpl",
    {
      tailscale_dir       = var.tailscale_dir
      tailscale_state_dir = var.tailscale_state_dir
      firewall_prefix     = local.firewall_prefix
    }
  )

  tailscale_tar_name = "tailscale_${var.tailscale_version}_${var.tailscale_arch}.tgz"
  tailscale_tar_url  = "https://pkgs.tailscale.com/stable/${local.tailscale_tar_name}"
}

resource "null_resource" "upload_tailscale_tar" {
  triggers = {
    device_ip          = var.device_ip
    tailscale_tar_url  = local.tailscale_tar_url
    tailscale_dir_hash = sha1(var.tailscale_dir)
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail
      # Only upload if not present
      ssh -o StrictHostKeyChecking=no -i ${var.ssh_private_key_file} ${var.ssh_user}@${var.device_ip} 'test -f /userdata/tailscale.tar' || \
      (curl -fsSL ${local.tailscale_tar_url} | gzip -d | ssh -o StrictHostKeyChecking=no -i ${var.ssh_private_key_file} ${var.ssh_user}@${var.device_ip} "cat > /userdata/tailscale.tar")
    EOT
  }
}

resource "null_resource" "extract_and_install" {
  triggers = {
    tver      = var.tailscale_version
    darch     = var.tailscale_arch
    device_ip = var.device_ip
  }

  depends_on = [null_resource.upload_tailscale_tar]

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail
      ssh -o StrictHostKeyChecking=no -i ${var.ssh_private_key_file} ${var.ssh_user}@${var.device_ip} '
        set -e
        cd /userdata
        # If directory not present, extract and move
        if [ ! -d "${var.tailscale_dir}" ]; then
          tar xf ./tailscale.tar
          # Move folder to constant name
          src_dir=$(ls -d tailscale_*_${var.tailscale_arch} | head -n1)
          if [ -n "$src_dir" ]; then
            mv "$src_dir" "${var.tailscale_dir}"
          fi
        fi
        chmod +x "${var.tailscale_dir}/tailscale" "${var.tailscale_dir}/tailscaled" || true
      '
    EOT
  }
}

resource "null_resource" "install_init_script" {
  triggers = {
    init_hash = sha1(local.init_template)
    device_ip = var.device_ip
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail
      tmpfile=$(mktemp)
      cat > "$tmpfile" <<'SCRIPT'
${local.init_template}
SCRIPT
      chmod 755 "$tmpfile"
      scp -o StrictHostKeyChecking=no -i ${var.ssh_private_key_file} "$tmpfile" ${var.ssh_user}@${var.device_ip}:/etc/init.d/S22tailscale || \
        ssh -o StrictHostKeyChecking=no -i ${var.ssh_private_key_file} ${var.ssh_user}@${var.device_ip} 'cat > /etc/init.d/S22tailscale' < "$tmpfile"
      ssh -o StrictHostKeyChecking=no -i ${var.ssh_private_key_file} ${var.ssh_user}@${var.device_ip} 'chmod +x /etc/init.d/S22tailscale'
      rm -f "$tmpfile"
    EOT
  }
}

resource "null_resource" "start_tailscaled" {
  triggers = {
    device_ip = var.device_ip
    init_hash = sha1(local.init_template)
  }

  depends_on = [null_resource.install_init_script, null_resource.extract_and_install]

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail
      ssh -o StrictHostKeyChecking=no -i ${var.ssh_private_key_file} ${var.ssh_user}@${var.device_ip} '
        /etc/init.d/S22tailscale stop || true
        /etc/init.d/S22tailscale start
      '
    EOT
  }
}

resource "null_resource" "tailscale_up" {
  triggers = {
    device_ip = var.device_ip
    tver      = var.tailscale_version
    xargs     = var.tailscale_extra_args
    auth_set  = tostring(var.tailscale_auth_key != null && length(var.tailscale_auth_key) > 0)
  }

  depends_on = [null_resource.start_tailscaled]

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail
      if [ "${var.tailscale_auth_key}" != "" ] && [ "${var.tailscale_auth_key}" != "null" ]; then
        ssh -o StrictHostKeyChecking=no -i ${var.ssh_private_key_file} ${var.ssh_user}@${var.device_ip} "${var.tailscale_dir}/tailscale up --authkey=${var.tailscale_auth_key} ${var.tailscale_extra_args} || true"
      else
        echo "No auth key provided; interactive device auth may be required."
        ssh -o StrictHostKeyChecking=no -i ${var.ssh_private_key_file} ${var.ssh_user}@${var.device_ip} "${var.tailscale_dir}/tailscale up ${var.tailscale_extra_args} || true"
      fi
    EOT
  }
}


