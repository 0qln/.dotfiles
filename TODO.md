# TODO

## Split DNS: resolve `*.07112025.xyz` to VPN IPs only when the tunnel is up

Status: deferred. Current (SSH-only) workaround is a `Host` alias in
`home/modules/ssh/default.nix`.

### Problem

SSH to lifbrasir is only reachable over the WireGuard VPN. `git.07112025.xyz`
(and the root host `07112025.xyz`) resolve to lifbrasir's **public** IP
(`91.8.108.154`), where port 22 is firewalled:

- `hosts/lifbrasir/configuration.nix` → `interfaces.wg_lifbrasir.allowedTCPPorts = [22]`
  (commit `5511146 "put ssh access behind vpn"`).
- lifbrasir's VPN address is `10.100.0.1` (the `.1` of `10.100.0.0/24`; see
  `dendrites/vars/nixos-defaults.nix`).

### Goal

Make `*.07112025.xyz` resolve to internal IPs (`10.100.0.1`) **only while the
VPN is up**, so every service (not just SSH) takes the internal path, while still
resolving to the public IP when off-VPN. TLS is unaffected: certs are name-based,
so `https://git.07112025.xyz` → `10.100.0.1` over the VPN still validates.

### Why the naive approach fails

`modules/networking/default.nix` already has a client-side `localDNS` option
(dnsmasq with `address=` redirects), but it is a **static, always-on** redirect:
`git.07112025.xyz → 10.100.0.1` would apply even off-VPN, breaking the public web
UI. It does not satisfy "only when the VPN is up". That file already carries a
TODO about the unicorn wireguard VPN needing a custom DNS entry.

### What's needed

1. **DNS server on lifbrasir** (none exists today). `dnsmasq` / `unbound` /
   `coredns` listening on `10.100.0.1`, answering `*.07112025.xyz` with internal
   records. Cloudflare stays authoritative for the public records.
2. **Conditional client routing** — use `10.100.0.1` for the `07112025.xyz` domain
   only while the `wg_0qln` link is up. Idiomatic mechanism: systemd-resolved
   per-link domains (`Domains=~07112025.xyz` on the wg interface). BUT freyja
   currently **disables** systemd-resolved (`modules/networking/default.nix` forces
   `services.resolved.enable = false` when `doh.enable`/`localDNS.enable`), so the
   DoH (dnscrypt-proxy) setup needs reworking too.
   Alternative: a wg `postUp`/`postDown` (NixOS `postSetup`/`postShutdown`) hook
   that toggles a local dnsmasq/dnscrypt redirect as the tunnel comes up/down.

### Open decisions

- DNS server choice on lifbrasir (dnsmasq vs unbound vs coredns/adguardhome).
- Re-enable systemd-resolved (per-link domains) vs the postUp/postDown toggle on
  the existing local dnsmasq.
- Redirect the whole `07112025.xyz` zone vs just `git.07112025.xyz` + root host.

### Related

- `modules/wireguard/template.nix` — client tunnel (split-tunnel `10.100.0.0/24`,
  endpoint = lifbrasir public FQDN, `persistentKeepalive 25`; now has a resume hook).
- `modules/wireguard-service/default.nix` — server side (lifbrasir): peers
  lif `.2`, freyja `.3`, loki-gylfi `.4`; server IP `10.100.0.1`.
- `modules/networking/default.nix` — client DNS (DoH via dnscrypt-proxy, optional
  localDNS dnsmasq).
