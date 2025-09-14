{
  adminpassFile,
  dbpassFile,
  dbpassFileHashed,
  fqdns,
}: {
  config,
  pkgs,
  lib,
  ...
}: let
  systemUser = "nextcloud";
  dbUser = "nextcloud";
  serviceName = "nextcloud";
  storagePath = "/mnt/store-1/services/nextcloud";
  hostNames = map (fqdn: "nextcloud.${fqdn}") fqdns;
  package = pkgs.nextcloud31;
  packages = pkgs.nextcloud31Packages;
in {
  imports = [
    ../database
    ../acme
    (import ./calendar.nix {inherit (packages) apps;})
  ];

  config = {
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
        sopsFile = dbpassFile;
        owner = systemUser;
        group = systemUser;
        mode = "0400";
        format = "binary";
      };

      # setting user password: https://github.com/Mic92/sops-nix?tab=readme-ov-file#setting-a-users-password
      "${serviceName}/dbpassHashed" = {
        sopsFile = dbpassFileHashed;
        format = "binary";
        neededForUsers = true;
      };

      "${serviceName}/adminpass" = {
        sopsFile = adminpassFile;
        owner = systemUser;
        group = systemUser;
        mode = "0400";
        format = "binary";
      };
    };

    services = {
      nginx.virtualHosts =
        lib.lists.foldl
        (acc: hostName:
          {
            ${hostName} = {
              enableACME = true;
              forceSSL = true;
            };
          }
          // acc)
        {}
        hostNames;

      nextcloud = {
        enable = true;
        inherit package;
        hostName = builtins.elemAt hostNames 0;
        home = storagePath;
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
          dbname = "nextcloud";

          dbuser = dbUser;
          dbpassFile = "/run/secrets/${serviceName}/dbpass";

          dbhost = "localhost:3306";
          adminuser = "root";
          adminpassFile = "/run/secrets/${serviceName}/adminpass";
        };
        settings = {
          default_phone_region = "DE";
          trusted_domains =
            [
              "192.168.178.50"
              "lifbrasir"
            ]
            ++ fqdns
            ++ hostNames;
        };
      };

      mysql = {
        ensureDatabases = ["nextcloud"];
        ensureUsers = [
          {
            name = dbUser;
            ensurePermissions = {
              "nextcloud.*" = "ALL PRIVILEGES";
            };
          }
        ];
      };
    };

    users.users.${dbUser} = {
      hashedPasswordFile = "/run/secrets-for-users/${serviceName}/dbpassHashed";
    };
  };
}
