{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.acme;
in {
  options.modules.acme = {
    enable = mkEnableOption "acme";
    duckdnsTokenFile = mkOption {
      type = types.path;
      description = "see https://www.duckdns.org/spec.jsp";
    };
    nginx-proxy-manager.enable = mkEnableOption "arion nginx-proxy-manager";
    certs.baseDn = {
      aliases = mkOption {
        type = types.listOf types.str;
        default = [];
      };
      name = mkOption {
        type = types.str;
      };
    };
  };

  # docs around acme:
  # https://nixos.org/manual/nixos/stable/index.html#module-security-acme
  config = mkIf cfg.enable {
    sops.secrets."acme/duckdnsToken" = {
      format = "binary";
      sopsFile = cfg.duckdnsTokenFile;
      owner = "acme";
    };

    users.users.nginx.extraGroups = ["acme"];

    security.acme = {
      acceptTerms = true;
      defaults = {
        email = "0qln@proton.me";
      };
      certs.${cfg.certs.baseDn.name} = mkMerge [
        # duckdns config
        {
          # https://go-acme.github.io/lego/dns/duckdns/
          dnsProvider = "duckdns";
          environmentFile = "${pkgs.writeText "duckdns-creds" ''
            DUCKDNS_PROPAGATION_TIMEOUT=340
            DUCKDNS_POLLING_INTERVAL=10
          ''}";
          credentialFiles = {
            "DUCKDNS_TOKEN_FILE" = config.sops.secrets."acme/duckdnsToken".path;
          };
          extraDomainNames = cfg.certs.baseDn.aliases;
          # https://github.com/go-acme/lego/discussions/2244#discussioncomment-11008783
          extraLegoFlags = [
            "--dns-timeout=20"
            "--dns.propagation-disable-ans"
          ];
        }

        # bypass the local DNS
        (mkIf config.modules.networking.localDNS.enable {
          dnsResolver = "1.1.1.1,8.8.8.8";
        })
      ];
    };

    # arion docs:
    # https://docs.hercules-ci.com/arion/deployment.html
    # https://docs.hercules-ci.com/arion/
    # https://nixos.wiki/wiki/Docker
    virtualisation.arion = mkIf cfg.nginx-proxy-manager.enable {
      backend = "docker";
      projects.example = rec {
        serviceName = "nginx-proxy-manager";
        settings = {
          # Specify you project here, or import it from a file.
          # NOTE: This does NOT use ./arion-pkgs.nix, but defaults to NixOS' pkgs.
          imports = [(import ./arion-compose.nix "/mnt/store-1/services/acme/${serviceName}")];
        };
      };
    };
  };
}
