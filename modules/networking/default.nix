{
  config,
  lib,
  utilz,
  ...
}:
with lib; let
  cfg = config.modules.networking;
in {
  options.modules.networking = {
    enable = mkEnableOption "networking module";
    doh = {
      enable = mkEnableOption "dns over https";
    };
    # todo: when enabling a local dns, the unicorn wireguard vpn breaks
    # because it requires a custom dns entry. figure out how to make the
    # wg-quick command write to dns entry to the local dns or something.
    localDNS = {
      enable = mkEnableOption "local dns server";
      redirects = mkOption {
        type = types.listOf types.str;
        description = "local redirects";
      };
    };
    baseDNS = mkOption {
      type = types.listOf types.str;
      default = [
        "1.1.1.1"
        "2606:4700:4700::1111"
      ];
    };
  };

  config = mkIf cfg.enable (mkMerge [
    # default config
    {
    }

    (mkIf (cfg.doh.enable || cfg.localDNS.enable) {
      # if we tamper with dns in any way, disable default dns stuff.
      services.resolved.enable = lib.mkForce false;
      networking = {
        nameservers = ["127.0.0.1" "::1"];
        # If using dhcpcd:
        dhcpcd.extraConfig = "nohook resolv.conf";
        # If using NetworkManager:
        networkmanager.dns = "none";
      };
    })

    (mkIf cfg.localDNS.enable (let
      dnscrypt = "5300";
    in {
      services.dnsmasq = {
        enable = true;
        settings = mkMerge [
          # default config
          {
            address = cfg.localDNS.redirects;
          }
          (utilz.mkIfElse cfg.doh.enable {
              # set upstream to dnscrypt
              server = ["127.0.0.1#${dnscrypt}" "::1#${dnscrypt}"];
            } {
              server = cfg.baseDNS;
            })
        ];
      };
      # dnscrypt integration
      services.dnscrypt-proxy = {
        # Rewrite dnscrypt to listen on some other port than 53
        settings.listen_addresses = ["127.0.0.1:${dnscrypt}" "[::1]:${dnscrypt}"];
      };
    }))

    (mkIf cfg.doh.enable {
      # https://nixos.wiki/wiki/Encrypted_DNS
      services.dnscrypt-proxy = {
        enable = true;
        # Settings reference:
        # https://github.com/DNSCrypt/dnscrypt-proxy/blob/master/dnscrypt-proxy/example-dnscrypt-proxy.toml
        settings = {
          ipv6_servers = true;
          require_dnssec = true;
          # Add this to test if dnscrypt-proxy is actually used to resolve DNS requests
          # query_log.file = "/var/log/dnscrypt-proxy/query.log";
          sources.public-resolvers = {
            urls = [
              "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
              "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
            ];
            cache_file = "/var/cache/dnscrypt-proxy/public-resolvers.md";
            minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
          };

          # You can choose a specific set of servers from https://github.com/DNSCrypt/dnscrypt-resolvers/blob/master/v3/public-resolvers.md
          # server_names = [  ];
        };
      };
    })
  ]);
}
