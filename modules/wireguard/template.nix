{
  ip,
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

          # Forward only the VPN subnet through the tunnel (split tunnel), so we
          # can reach the server over it (e.g. ssh 10.100.0.1) without routing
          # all traffic through it. A full tunnel (0.0.0.0/0) would need fwmark
          # + policy routing to avoid looping the tunnel's own packets.
          allowedIPs = [
            "10.100.0.0/24"
          ];

          # Set this to the server IP and port.
          endpoint = "${serverAddress}:${toString serverPort}"; # ToDo: route to endpoint not automatically configured https://wiki.archlinux.org/index.php/WireGuard#Loop_routing https://discourse.nixos.org/t/solved-minimal-firewall-setup-for-wireguard-client/7577

          # Send keepalives every 25 seconds. Important to keep NAT tables alive.
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
