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

  imports = [
    ../acme
  ];

  config = mkIf cfg.enable {
    services.nginx.virtualHosts."${cfg.primaryFqdn}" = {
      # enableACME = true;
      forceSSL = true;
      useACMEHost = "gitea.0qln.duckdns.org";
      locations."/" = {
        proxyPass = "http://localhost:${toString port}/";
      };
    };

    services.postgresql = {
      ensureDatabases = [config.services.gitea.user];
      ensureUsers = [
        {
          name = config.services.gitea.database.user;
          ensureDBOwnership = true;
        }
      ];
    };

    sops.secrets."postgres/gitea_dbpass" = {
      sopsFile = cfg.dbpassFile;
      format = "binary";
      owner = config.services.gitea.user;
    };

    services.gitea = {
      enable = true;
      appName = "( ᵕ༚ᵕ )\̅_̅/̷̚ʾ Mhm.. yes very nice — *slurrrp*";
      database = {
        type = "postgres";
        passwordFile = config.sops.secrets."postgres/gitea_dbpass".path;
      };
      settings.server = {
        DOMAIN = cfg.primaryFqdn;
        ROOT_URL = "https://${cfg.primaryFqdn}/";
        HTTP_PORT = port;
      };
    };
  };
}
