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

    anubis.enable = mkEnableOption {
      description = "Bot/scraper protection via anubis";
    };
  };

  config = mkIf cfg.enable {
    modules.acme.certs.${cfg.fqdn.acmeHost}.aliases = [cfg.fqdn.dn];

    users.users.nginx.extraGroups = mkIf cfg.anubis.enable ["anubis"];

    services = {
      nginx = {
        recommendedProxySettings = true;
        recommendedTlsSettings = true;

        virtualHosts = let
          proxyGitea = "http://localhost:${toString port}";
          proxyAnubis = "http://unix:/run/anubis/anubis-gitea/anubis.sock:";
        in {
          "${cfg.fqdn.dn}" = mkMerge [
            # Default
            {
              forceSSL = true;
              useACMEHost = cfg.fqdn.acmeHost;
              locations."/".extraConfig =
                # nginx
                ''
                  client_max_body_size 512M;
                '';
            }

            # Gitea
            (mkIf (!cfg.anubis.enable) {
              locations."/" = {
                proxyPass = "${proxyGitea}/";
              };
            })

            # Anubis
            (mkIf cfg.anubis.enable {
              locations = {
                # api logins
                "/api/v1/user" = {proxyPass = "${proxyGitea}/api/v1/user";};
                "/api/v1/user/keys" = {proxyPass = "${proxyGitea}/api/v1/user/keys";};

                # anything else
                "/" = {
                  proxyPass = "${proxyAnubis}/";
                  extraConfig =
                    # nginx
                    ''
                      proxy_set_header X-Real-Ip $remote_addr;
                    '';
                };
              };
            })
          ];
        };
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
        lfs.enable = true;
        stateDir = "${cfg.serviceDataDir}";
        settings = {
          server = {
            DOMAIN = cfg.fqdn.dn;
            ROOT_URL = "https://${cfg.fqdn.dn}/";
            LOCAL_ROOT_URL = mkIf cfg.anubis.enable "http://localhost:${toString port}";
            HTTP_PORT = port;
          };
          repository = {
            ENABLE_PUSH_CREATE_USER = true;
            DISABLE_STARS = true;
            ALLOW_FORK_INTO_SAME_OWNER = true;
          };
          "repository.upload" = {
            FILE_MAX_SIZE = 1024;
            LFS_MAX_FILE_SIZE = 1024;
          };
          service.DISABLE_REGISTRATION = true;
          security = {
            REVERSE_PROXY_TRUSTED_PROXIES = "127.0.0.0/8,::1/128";
          };
        };
      };

      anubis.instances."gitea" = mkIf cfg.anubis.enable {
        enable = true;
        settings = {
          TARGET = "http://localhost:${toString port}";
          REDIRECT_DOMAINS = cfg.fqdn.dn;
          PUBLIC_URL = "https://${cfg.fqdn.dn}";
          COOKIE_DOMAIN = cfg.fqdn.dn;
          OG_PASSTHROUGH = true;
          BIND = "/run/anubis/anubis-gitea/anubis.sock";
          METRICS_BIND = "/run/anubis/anubis-gitea/anubis-metrics.sock";
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
