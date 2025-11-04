{
  ip,
  privateKeyFile,
  serverAddress,
  serverPort ? 51820,
  serverPubKey,
  vpnName,
}: {
  host-name,
  config,
  ...
}: let
  port = 51820;
  privateKey = "wg/${host-name}/privateKey";
in {
  networking.firewall = {
    allowedUDPPorts = [port]; # Clients and peers can use the same port, see listenport
  };

  sops.secrets.${privateKey} = {
    sopsFile = privateKeyFile;
    format = "binary";
    mode = "0400";
  };

  networking.wireguard.interfaces = {
    # The network interface name. You can name the interface arbitrarily.
    "wg_${vpnName}" = {
      # Determines the IP address and subnet of the client's end of the tunnel interface.
      ips = [ip];
      listenPort = port; # to match firewall allowedUDPPorts (without this wg uses random port numbers)

      # Path to the private key file.
      privateKeyFile = config.sops.secrets.${privateKey}.path;

      peers = [
        # For a client configuration, one peer entry for the server will suffice.

        {
          # Public key of the server (not a file path).
          publicKey = serverPubKey;

          # Forward all the traffic via VPN.
          allowedIPs = [
            "0.0.0.0/0"
            # "::/0"
          ];
          # Or forward only particular subnets
          #allowedIPs = [ "10.100.0.1" "91.108.12.0/22" ];

          # Set this to the server IP and port.
          endpoint = "${serverAddress}:${toString serverPort}"; # ToDo: route to endpoint not automatically configured https://wiki.archlinux.org/index.php/WireGuard#Loop_routing https://discourse.nixos.org/t/solved-minimal-firewall-setup-for-wireguard-client/7577

          # Send keepalives every 25 seconds. Important to keep NAT tables alive.
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
