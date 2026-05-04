{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  serviceName = "vikunja";
  cfg = config.modules.vikunja;
in {
  options.modules.vikunja = {
    enable = mkEnableOption "vikunja";

    serviceDataDir = mkOption {
      type = types.str;
      description = "The storage path for the home directory.";
    };

    primaryFqdn = mkOption {
      type = types.str;
      description = "The primary fqdn.";
    };

    acmeHost = mkOption {
      type = types.str;
      description = "The host domain that has an ssl certificate.";
    };

    port = mkOption {
      type = types.int;
      default = 3456;
      description = "The port vikunja listens on.";
    };

    secretsFile = mkOption {
      type = types.path;
      description = "The path to the encrypted environment file containing.";
    };
  };

  config = mkIf cfg.enable {
    modules.acme.certs.${cfg.acmeHost}.aliases = [cfg.primaryFqdn];

    sops.secrets = {
      "${serviceName}/secrets.env" = {
        sopsFile = cfg.secretsFile;
        mode = "0400";
        format = "dotenv";
      };
    };

    services = {
      nginx.virtualHosts = {
        ${cfg.primaryFqdn} = {
          useACMEHost = cfg.acmeHost;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://localhost:${(toString cfg.port)}";
          };
        };
      };

      vikunja = {
        enable = true;
        package = pkgs.vikunja;

        database = {type = "postgres";};

        settings = {
          # https://vikunja.io/docs/config-options#1-service-enableregistration
          service.enableregistration = false;

          # https://vikunja.io/docs/config-options/#1-service-rootpath
          service.rootpath = "${cfg.serviceDataDir}/root";

          # https://vikunja.io/docs/config-options/#1-files-basepath
          files.basepath = mkForce "${cfg.serviceDataDir}/files";

          migration.todoist = {
            enable = true;
          };

          auth = {
            # https://vikunja.io/docs/openid/#step-2-configure-vikunja
            openid = {
              enabled = true;
            };

            # https://vikunja.io/docs/openid/#login-existing-local-user-with-openid
            local = {
              enabled = true;
            };
          };
        };

        environmentFiles = [
          config.sops.secrets."${serviceName}/secrets.env".path
        ];

        frontendHostname = cfg.primaryFqdn;
        frontendScheme = "https";

        inherit (cfg) port;
      };

      postgresql = {
        ensureDatabases = [config.services.vikunja.database.database];
        ensureUsers = [
          {
            name = config.services.vikunja.database.user;
            ensureDBOwnership = true;
            # note: the password has to be configured imperatively
            # could do it like this https://wiki.nixos.org/wiki/PostgreSQL but that feels weird ngl
          }
        ];
      };
    };

    # ensure files exist with respective permissions
    systemd.services.vikunja = let
      dir = cfg.serviceDataDir;
    in {
      serviceConfig = {
        ExecStartPre = [
          "+${pkgs.coreutils}/bin/mkdir -p ${dir}/root"
          "+${pkgs.coreutils}/bin/mkdir -p ${dir}/files"
          "+${pkgs.coreutils}/bin/chown -R vikunja:vikunja ${dir}"
        ];
        ReadWritePaths = mkForce dir;
        ProtectSystem = mkForce "yes";
      };
    };
  };
}
