{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.my-services.gitea;
  port = 3001;
in {
  options.my-services.gitea = {
    enable = mkEnableOption "gitea";

    primaryFqdn = mkOption {
      type = types.str;
      description = "The primary fqdn.";
    };

    dbpassFile = mkOption {
      type = types.path;
      description = "Database password file";
    };
  };

  config = mkIf cfg.enable {
    modules.acme.certs.baseDn.aliases = [cfg.primaryFqdn];

    services = {
      nginx.virtualHosts."${cfg.primaryFqdn}" = {
        forceSSL = true;
        useACMEHost = "0qln.duckdns.org";
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
        settings = {
          server = {
            DOMAIN = cfg.primaryFqdn;
            ROOT_URL = "https://${cfg.primaryFqdn}/";
            HTTP_PORT = port;
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
