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
            "10.100.0.1/24"
            "fd00::1/64"
          ];

          # The port that WireGuard listens to. Must be accessible by the client.
          listenPort = port;

          # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
          # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice)
          # in your clients
          postSetup = ''
            ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o ${cfg.externalInterface} -j MASQUERADE
          '';

          # This undoes the above command
          postShutdown = ''
            ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o ${cfg.externalInterface} -j MASQUERADE
          '';

          # Path to the private key file.
          privateKeyFile = config.sops.secrets.${privateKey}.path;

          peers = [
            # List of allowed peers.
            {
              # lif
              publicKey = builtins.readFile ../../hosts/lif/wireguard/0qln/public.key;
              allowedIPs = ["10.100.0.2/32"];
            }
          ];
        };
      };
    };
  };
}
