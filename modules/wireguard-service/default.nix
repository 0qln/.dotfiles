{
  pkgs,
  host-name,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.wireguard-service;

  port = 51820;
  interface = "wg_${host-name}";
  privateKey = "wg/${host-name}/privateKey";

  # Tunnel addresses, sourced from the shared host facts (dendrites/vars).
  # serverIp is the host's own address (derived from vpnNet in vars); vpnNet
  # is the subnet, used for MASQUERADE.
  serverIp = config.vars.hosts.${host-name}.vpnIp;
  vpnNet = config.vars.hosts.${host-name}.vpnNet;
in {
  options.modules.wireguard-service = {
    enable = mkEnableOption "wireguard service";
    privateKeyFile = mkOption {
      type = types.path;
    };
    externalInterface = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    sops.secrets.${privateKey} = {
      sopsFile = cfg.privateKeyFile;
      format = "binary";
      mode = "0400";
    };

    networking = {
      nat = {
        enable = true;
        inherit (cfg) externalInterface;
        internalInterfaces = [interface];
      };

      firewall = {
        allowedUDPPorts = [port];
      };

      wireguard.interfaces = {
        ${interface} = {
          # Determines the IP address and subnet of the server's end of the tunnel interface.
          ips = [
            "${serverIp}/24"
            "fd00::1/64"
          ];

          # The port that WireGuard listens to. Must be accessible by the client.
          listenPort = port;

          # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
          # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice)
          # in your clients
          postSetup = ''
            ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s ${vpnNet}/24 -o ${cfg.externalInterface} -j MASQUERADE
          '';

          # This undoes the above command
          postShutdown = ''
            ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s ${vpnNet}/24 -o ${cfg.externalInterface} -j MASQUERADE
          '';

          # Path to the private key file.
          privateKeyFile = config.sops.secrets.${privateKey}.path;

          peers = [
            # List of allowed peers.
            {
              # lif
              publicKey = builtins.readFile (../../hosts + "/lif?dendrite/wireguard/0qln/public.key");
              allowedIPs = ["10.100.0.2/32"];
            }
            {
              # freyja
              publicKey = builtins.readFile (../../hosts + "/freyja/wireguard/0qln/public.key");
              allowedIPs = ["10.100.0.3/32"];
            }
            {
              # loki-gylfi (wsl)
              publicKey = builtins.readFile (../../hosts + "/loki.gylfi/wireguard/0qln/public.key");
              allowedIPs = ["10.100.0.4/32"];
            }
          ];
        };
      };
    };
  };
}
