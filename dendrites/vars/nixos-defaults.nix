{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.vars;

  # The first host address of a subnet in CIDR form, e.g. "10.100.0.0/24" ->
  # "10.100.0.1". The wireguard server takes the .1 address of its subnet.
  firstHost = net: concatStringsSep "." (init (splitString "." (head (splitString "/" net))) ++ ["1"]);
in {
  config.vars = {
    system = mkDefault "x86_64-linux";

    home.config.backup = {
      extension = "hm-bac";
      command = "${getExe pkgs.trashy}";
    };

    domains = {
      "0qln.duckdns.org" = {
        dn = "0qln.duckdns.org";
        registrar = "duckdns";
      };
      "07112025.xyz" = {
        dn = "07112025.xyz";
        registrar = "cloudflare";
      };
      "oq.404.mn" = {
        dn = "oq.404.mn";
        registrar = "afraid";
      };
      "nextcloud.myaddr.dev" = {
        dn = "nextcloud.myaddr.dev";
        registrar = "";
      };
    };

    hosts = {
      lifbrasir = let
        net = "10.100.0.0/24";
      in {
        fqdns = {
          all = [
            "0qln.duckdns.org"
            "07112025.xyz"
          ];
          primary = cfg.domains."07112025.xyz";
        };
        vpnNet = net;
        vpnIp = firstHost net;
      };
    };
  };
}
