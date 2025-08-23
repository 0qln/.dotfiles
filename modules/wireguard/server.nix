{ privateKeyFile }:
{ pkgs, host-name, ... }:
let
  port = 51820;
in
{
  networking = {
    nat = {
      # enable NAT
      enable = true;
      externalInterface = "eth0";
      internalInterfaces = [ "wg_${host-name}" ];
    };

    firewall = {
      allowedUDPPorts = [ port ];
    };

    wireguard.interfaces = {
      "wg_${host-name}" = {
        # Determines the IP address and subnet of the server's end of the tunnel interface.
        ips = [ "10.100.0.1/24" ];

        # The port that WireGuard listens to. Must be accessible by the client.
        listenPort = port;

        # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
        # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
        postSetup = ''
          ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
        '';

        # This undoes the above command
        postShutdown = ''
          ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
        '';

        # Path to the private key file.
        inherit privateKeyFile;

        peers = [
          # List of allowed peers.
          {
            # Feel free to give a meaningful name
            # Public key of the peer (not a file path).
            publicKey = "{client public key}";
            # List of IPs assigned to this peer within the tunnel subnet. Used to configure routing.
            allowedIPs = [ "10.100.0.2/32" ];
          }
          {
            # John Doe
            publicKey = "{john doe's public key}";
            allowedIPs = [ "10.100.0.3/32" ];
          }
        ];
      };
    };
  };
}
