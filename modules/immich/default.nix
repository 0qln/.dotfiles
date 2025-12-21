{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.immich;
in {
  options.modules.immich = {
    enable = mkEnableOption "immich";

    fqdn = {
      dn = mkOption {
        type = types.str;
        description = "The primary fqdn.";
      };
      acmeHost = mkOption {
        type = types.str;
        description = "The host domain that has an ssl certificate.";
      };
    };

    port = mkOption {
      type = types.int;
      default = 2283;
    };

    serviceDataDir = mkOption {
      type = types.str;
      default = "/mnt/store-1/services/immich";
    };

    secretsFile = mkOption {
      type = types.path;
      description = "Secrets file";
    };
  };
  config = mkIf cfg.enable {
    modules.acme.certs.${cfg.fqdn.acmeHost}.aliases = [cfg.fqdn.dn];

    sops.secrets."immich/secrets.env" = {
      sopsFile = cfg.secretsFile;
      format = "dotenv";
      "owner" = config.services.immich.user;
      "group" = config.services.immich.group;
    };

    services = {
      nginx = {
        virtualHosts."${cfg.fqdn.dn}" = {
          forceSSL = true;
          useACMEHost = cfg.fqdn.acmeHost;
          locations."/" = {
            proxyPass = "http://localhost:${toString cfg.port}/";
            proxyWebsockets = true;
            recommendedProxySettings = true;
            extraConfig =
              # nginx
              ''
                client_max_body_size 50000M;
                proxy_read_timeout   600s;
                proxy_send_timeout   600s;
                send_timeout         600s;
              '';
          };
        };
      };

      immich = {
        enable = true;
        inherit (cfg) port;
        mediaLocation = cfg.serviceDataDir;
        secretsFile = config.sops.secrets."immich/secrets.env".path;
        database = {
          inherit (config.services.postgresql.settings) port;
        };
      };
    };

    systemd.tmpfiles.rules = [
      "d ${dirOf cfg.serviceDataDir} 0755 root root - -"
      "d ${cfg.serviceDataDir} 0700 ${config.services.immich.user} ${config.services.immich.group} - -"
    ];
  };
}
