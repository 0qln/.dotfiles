{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.gitea;
  port = 3001;
in {
  options.modules.gitea = {
    enable = mkEnableOption "gitea";

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

    dbpassFile = mkOption {
      type = types.path;
      description = "Database password file";
    };

    serviceDataDir = mkOption {
      type = types.str;
      default = "/mnt/store-1/services/gitea/data";
    };
  };

  config = mkIf cfg.enable {
    modules.acme.certs.${cfg.fqdn.acmeHost}.aliases = [cfg.fqdn.dn];

    services = {
      nginx.virtualHosts."${cfg.fqdn.dn}" = {
        forceSSL = true;
        useACMEHost = cfg.fqdn.acmeHost;
        locations."/" = {
          proxyPass = "http://localhost:${toString port}/";
        };
      };

      nginx = {
        recommendedProxySettings = true;
        recommendedTlsSettings = true;
      };

      postgresql = {
        ensureDatabases = [config.services.gitea.user];
        ensureUsers = [
          {
            name = config.services.gitea.database.user;
            ensureDBOwnership = true;
          }
        ];
      };

      gitea = {
        enable = true;
        appName = "( ᵕ༚ᵕ )\̅_̅/̷̚ʾ Mhm.. yes very nice — *slurrrp*";
        database = {
          type = "postgres";
          passwordFile = config.sops.secrets."postgres/gitea_dbpass".path;
        };
        lfs = {
          enable = true;
          contentDir = "${cfg.serviceDataDir}/lfs";
        };
        settings = {
          server = {
            DOMAIN = cfg.fqdn.dn;
            ROOT_URL = "https://${cfg.fqdn.dn}/";
            HTTP_PORT = port;
          };

          "repository.upload" = {
            FILE_MAX_SIZE = 1024;
            LFS_MAX_FILE_SIZE = 1024;
          };

          # Don't allow anyone to create an account
          service.DISABLE_REGISTRATION = true;
        };
      };
    };

    sops.secrets."postgres/gitea_dbpass" = {
      sopsFile = cfg.dbpassFile;
      format = "binary";
      owner = config.services.gitea.user;
    };
  };
}
