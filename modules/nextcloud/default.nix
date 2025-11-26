{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  serviceName = "nextcloud";
  package = pkgs.nextcloud32;
  packages = pkgs.nextcloud32Packages;
  cfg = config.modules.${serviceName};
in {
  imports = [
    ./calendar.nix
    ./tasks.nix
  ];

  options.modules.${serviceName} = {
    enable = mkEnableOption serviceName;

    storagePath = mkOption {
      type = types.str;
      description = "The storage path for the home directory.";
    };

    serviceSystemUser = mkOption {
      type = types.str;
      default = "nextcloud";
      description = "The user that this service will operate under.";
    };

    serviceSystemGroup = mkOption {
      type = types.str;
      default = "nextcloud";
      description = "The group of the serviceUser.";
    };

    dbSystemUser = mkOption {
      type = types.str;
      default = "nextcloud";
      description = "The user that this service will operate under.";
    };

    dbHost = mkOption {
      type = types.str;
      default = "localhost:3306";
      description = "The database host.";
    };

    dbUser = mkOption {
      type = types.str;
      default = "nextcloud";
      description = "The database user account for this service.";
    };

    dbName = mkOption {
      type = types.str;
      default = "nextcloud";
      description = "The name of the database";
    };

    adminpassFile = mkOption {
      type = types.path;
      description = "The path to the encrypted admin pass file.";
    };

    dbpassFile = mkOption {
      type = types.path;
      description = "The path to the encrypted db password file.";
    };

    dbpassFileHashed = mkOption {
      type = types.path;
      description = "The path to the encrypted db pass user password file.";
    };

    primaryFqdn = mkOption {
      type = types.str;
      description = "The primary fqdn.";
    };
    acmeHost = mkOption {
      type = types.str;
      description = "The host domain that has an ssl certificate.";
    };

    localFqdns = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Local fsdns.";
    };

    _apps = mkOption {
      type = types.attrs;
      description = "The apps.";
      internal = true;
    };
  };

  config = mkIf cfg.enable {
    modules.nextcloud._apps = packages.apps;

    networking.firewall = {
      allowedTCPPorts = [
        443
        80
      ];
      allowedUDPPorts = [
        53
      ];
    };

    sops.secrets = {
      "${serviceName}/dbpass" = {
        sopsFile = cfg.dbpassFile;
        owner = cfg.serviceSystemUser;
        group = cfg.serviceSystemUser;
        mode = "0400";
        format = "binary";
      };

      # setting user password: https://github.com/Mic92/sops-nix?tab=readme-ov-file#setting-a-users-password
      "${serviceName}/dbpassHashed" = {
        sopsFile = cfg.dbpassFileHashed;
        format = "binary";
        neededForUsers = true;
      };

      "${serviceName}/adminpass" = {
        sopsFile = cfg.adminpassFile;
        owner = cfg.serviceSystemUser;
        group = cfg.serviceSystemUser;
        mode = "0400";
        format = "binary";
      };
    };

    modules.acme.certs.${cfg.acmeHost}.aliases = [cfg.primaryFqdn];

    services = {
      nginx.virtualHosts = {
        ${cfg.primaryFqdn} = {
          useACMEHost = cfg.acmeHost;
          forceSSL = true;
        };
      };

      nextcloud = {
        enable = true;
        inherit package;
        hostName = cfg.primaryFqdn;
        home = cfg.storagePath;
        database.createLocally = false;
        enableImagemagick = true;
        https = true;
        extraAppsEnable = true;
        appstoreEnable = true;
        autoUpdateApps = {
          enable = true;
          startAt = "Sun 13:00:00";
        };
        config = {
          dbtype = "mysql";
          dbname = cfg.dbName;

          dbuser = cfg.dbUser;
          dbpassFile = "/run/secrets/${serviceName}/dbpass";

          dbhost = cfg.dbHost;
          adminuser = "root";
          adminpassFile = "/run/secrets/${serviceName}/adminpass";
        };
        settings = rec {
          default_phone_region = "DE";
          trusted_domains = [cfg.primaryFqdn] ++ cfg.localFqdns;
          enable_previews = true;
          enabledPreviewProviders = [
            "OC\\Preview\\PNG"
            "OC\\Preview\\JPEG"
            "OC\\Preview\\GIF"
            "OC\\Preview\\BMP"
            "OC\\Preview\\XBitmap"
            "OC\\Preview\\MP3"
            "OC\\Preview\\TXT"
            "OC\\Preview\\MarkDown"
            "OC\\Preview\\OpenDocument"
            "OC\\Preview\\Krita"
            "OC\\Preview\\HEIC"
          ];
          # trusted_proxies =
          #   [
          #     "127.0.0.1"
          #     "::1"
          #   ]
          #   ++ trusted_domains;
        };
      };

      mysql = {
        ensureDatabases = [cfg.dbName];
        ensureUsers = [
          {
            name = cfg.dbUser;
            ensurePermissions = {
              "${cfg.dbName}.*" = "ALL PRIVILEGES";
            };
          }
        ];
      };
    };

    users.users.${cfg.dbUser} = {
      hashedPasswordFile = "/run/secrets-for-users/${serviceName}/dbpassHashed";
    };
  };
}
