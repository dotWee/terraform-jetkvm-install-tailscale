> **Archived as of 2026-02-07 - use the [official tailscale install script](https://jetkvm.com/docs/networking/remote-access#tailscale) from JetKVM**

---

# Tailscale on JetKVM through Terraform

This project installs and configures Tailscale on a JetKVM device (BusyBox/dropbear) using Terraform provisioners.

It follows the approach described by Brandon Tuttle [@tutman96](https://github.com/tutman96) in his tutorial _[Installing Tailscale on JetKVM](https://medium.com/@brandontuttle/installing-tailscale-on-a-jetkvm-3c72355b7eb0)_ and automates the end-to-end procedure including upload, extraction, init script installation, daemon start, and `tailscale up` through Terraform.

> **Note:** Per the tutorial, `/etc/init.d` contents are not persistent across OS updates. After a JetKVM OS upgrade, re-apply this Terraform to restore `S22tailscale`.

Features include:

- Pulls and uploads Tailscale static tar via SSH pipe (no `scp` required on JetKVM)
- Installs binaries under `/userdata/tailscale/`
- Creates `/etc/init.d/S22tailscale` to start `tailscaled` on boot
- Starts `tailscaled` and runs `tailscale up` with optional auth key and flags
- Idempotent guards and Terraform triggers to re-run when inputs change

## Quick Start

> **Note:** JetKVM set up normally with Developer Mode enabled and your SSH public key added (see JetKVM docs).
> Your workstation has `terraform`, `ssh`, `curl`, and `gzip` available (macOS & Linux works well).

1. Configure variables via a `.tfvars` file or environment variables. Example `terraform.tfvars`:

    ```hcl
    device_ip            = "10.10.0.6"
    ssh_private_key_file = pathexpand("~/.ssh/id_ed25519")
    tailscale_version    = "1.88.3"
    tailscale_auth_key   = null # or "tskey-auth-..." if using key auth
    tailscale_extra_args = "--advertise-tags=tag:jetkvm"
    ```

    Alternatively export secrets safely:

    ```bash
    export TF_VAR_tailscale_auth_key="tskey-auth-..."
    ```

2. Initialize and apply:

    ```bash
    terraform init
    terraform plan -out plan.out
    terraform apply plan.out
    ```

3. Verify on the device:

    ```bash
    ssh root@$JETKVM_IP \
      -i $SSH_PRIVATE_KEY_FILE \
      "/userdata/tailscale/tailscale status || true"
    ```

    If no auth key is provided, `tailscale up` will prompt for interactive device auth. Follow the URL to add the JetKVM to your Tailnet.

## Terraform Module

The module is located in [`modules/tailscale-jetkvm`](modules/tailscale-jetkvm).

Key inputs (see [`variables.tf`](modules/tailscale-jetkvm/variables.tf) for all):

- `device_ip` (string): JetKVM IP, for example `10.10.0.6`.
- `ssh_user` (string): SSH user, defaults to `root`.
- `ssh_private_key_file` (string): Path to your private key.

### Variables

Key inputs (see [`variables.tf`](variables.tf) for all):

- `device_ip` (string): JetKVM IP, for example `10.10.0.6`.
- `ssh_user` (string): SSH user, defaults to `root`.
- `ssh_private_key_file` (string): Path to your private key.
- `tailscale_version` (string): Tailscale version, e.g., `1.88.3`.
- `tailscale_arch` (string): Architecture, defaults to `arm`.
- `tailscale_dir` (string): Defaults to `/userdata/tailscale`.
- `tailscale_state_dir` (string): Defaults to `/userdata/tailscale-state`.
- `tailscale_auth_key` (sensitive string or null): Auth key for non-interactive setup.
- `tailscale_extra_args` (string): Extra flags for `tailscale up`.
- `nftables_mode` (bool): Enables `TS_DEBUG_FIREWALL_MODE=nftables`.

### Outputs

- `device_ip`
- `tailscale_dir`
- `tailscale_state_dir`

### Operations

- Upgrade Tailscale: change `tailscale_version` and re-apply.
- Change args (tags, routes): update `tailscale_extra_args` and re-apply.
- OS update on JetKVM: re-apply to restore `/etc/init.d/S22tailscale`.

## Troubleshooting

- Connectivity: ensure you can SSH to the device IP as `root`.
- Auth key issues: export `TF_VAR_tailscale_auth_key` to avoid committing secrets.
- Verify running:

    ```bash
    ssh root@<ip> -i <key> "/userdata/tailscale/tailscale status"
    ```

- If `tailscaled` fails on boot but works when run later, check `/tmp/ts.log` on the device and ensure `/dev/net/tun` exists. The init script now attempts `modprobe tun` and retries for up to ~10s. See: [Getting Tailscale to work on my JetKVM](https://shanemcd.com/posts/04-jetkvm-tailscale)

### Note on non-persistent MAC address

Some JetKVM firmware versions may assign a new MAC on reboot, causing DHCP to issue new IPs. Track firmware issues and consider DHCP reservations that match the current MAC or a firmware update as fixes emerge. See discussion mentioned in [Getting Tailscale to work on my JetKVM](https://shanemcd.com/posts/04-jetkvm-tailscale).

## Linting and Validation

Run Terraform formatting and basic validation before applying:

```bash
terraform fmt -recursive
terraform validate
```

Optional: run `tflint`:

```bash
tflint --init || true
tflint
```

## References

- [Installing Tailscale on JetKVM](https://medium.com/@brandontuttle/installing-tailscale-on-a-jetkvm-3c72355b7eb0) by Brandon Tuttle ([@tutman96](https://github.com/tutman96))
- [Getting Tailscale to work on my JetKVM](https://shanemcd.com/posts/04-jetkvm-tailscale) by Shane McDonald ([@shanemcd](https://github.com/shanemcd))

## License

Copyright (C) 2025 Lukas 'dotWee' Wolfsteiner <lukas@wolfsteiner.media>

Licensed under the [_Do What The fuck You Want To_](/LICENSE) public license.
