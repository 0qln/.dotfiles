{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.acme;
in {
  options.modules.acme = let
    certType = types.submodule {
      options = {
        registrar = mkOption {type = types.str;};
        aliases = mkOption {
          type = types.listOf types.str;
          default = [];
        };
        duckdnsInfos.tokenFile = mkOption {
          type = types.path;
          description = "see https://www.duckdns.org/spec.jsp";
        };
        cloudflareInfos.tokenFile = mkOption {
          type = types.path;
          description = "api token with permissions Zone/Zone/Read and Zone/DNS/Edit; see https://go-acme.github.io/lego/dns/cloudflare/index.html";
        };
      };
    };
  in {
    enable = mkEnableOption "acme";
    certs = mkOption {
      type = types.attrsOf certType;
      description = "map from dn to infos";
    };
    nginx-proxy-manager.enable = mkEnableOption "arion nginx-proxy-manager";
  };

  # docs around acme:
  # https://nixos.org/manual/nixos/stable/index.html#module-security-acme
  config = mkIf cfg.enable {
    sops.secrets = let
      templates = {
        "duckdns" = infos: {
          "token" = {
            format = "binary";
            sopsFile = infos.duckdnsInfos.tokenFile;
            owner = "acme";
          };
        };
        "cloudflare" = infos: {
          "token" = {
            format = "binary";
            sopsFile = infos.cloudflareInfos.tokenFile;
            owner = "acme";
          };
        };
      };
    in
      builtins.listToAttrs (lists.flatten (
        attrsets.mapAttrsToList
        (
          domain: infos: (
            attrsets.mapAttrsToList
            (secretName: secret: (nameValuePair "acme/${domain}/${secretName}" secret))
            (templates.${infos.registrar} infos)
          )
        )
        cfg.certs
      ));

    users.users.nginx.extraGroups = ["acme"];

    security.acme = {
      acceptTerms = true;
      defaults = {
        email = "0qln@proton.me";
      };

      certs = let
        templates = {
          "duckdns" = {
            domain,
            infos,
            ...
          }:
            mkMerge [
              (mkIf true {
                # https://go-acme.github.io/lego/dns/duckdns/
                dnsProvider = "duckdns";
                environmentFile = "${pkgs.writeText "duckdns-creds" ''
                  DUCKDNS_PROPAGATION_TIMEOUT=340
                  DUCKDNS_POLLING_INTERVAL=10
                ''}";
                credentialFiles = {
                  "DUCKDNS_TOKEN_FILE" = config.sops.secrets."acme/${domain}/token".path;
                };
                extraDomainNames = infos.aliases;
                # https://github.com/go-acme/lego/discussions/2244#discussioncomment-11008783
                extraLegoFlags = [
                  "--dns-timeout=20"
                  "--dns.propagation-disable-ans"
                ];
              })
              (mkIf config.modules.networking.localDNS.enable {
                dnsResolver = "1.1.1.1,8.8.8.8";
              })
            ];

          "cloudflare" = {
            domain,
            infos,
            ...
          }:
            mkMerge [
              (mkIf true {
                dnsProvider = "cloudflare";
                credentialFiles = {
                  "CF_DNS_API_TOKEN_FILE" = config.sops.secrets."acme/${domain}/token".path;
                };
                extraDomainNames = infos.aliases;
              })
              (mkIf config.modules.networking.localDNS.enable {
                dnsResolver = "1.1.1.1,8.8.8.8";
              })
            ];
        };
      in
        builtins.mapAttrs (domain: infos: (templates.${infos.registrar} {inherit domain infos;})) cfg.certs;
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
