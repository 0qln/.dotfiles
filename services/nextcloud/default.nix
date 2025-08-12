{
  adminpassFile,
  dbpassFile,
  dbpassFileHashed,
}:
{
  config,
  pkgs,
  lib,
  ...
}:
let
  systemUser = "nextcloud";
  dbUser = "nextcloud";
  serviceName = "nextcloud";
  storagePath = "/mnt/store-1/services/nextcloud";
in
{
  imports = [
    ../database
  ];

  config = {

    networking.firewall.allowedTCPPorts = [
      443
      80
    ];

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

    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud31;
      hostName = "localhost";
      home = storagePath;
      database.createLocally = false;
      enableImagemagick = true;
      extraAppsEnable = true;
      extraApps = {
        # TODO

      };
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
        trusted_domains = [ "192.168.178.50" ];
      };
    };

    users.users.${dbUser} = {
      hashedPasswordFile = "/run/secrets-for-users/${serviceName}/dbpassHashed";
    };

    services.mysql = {
      ensureDatabases = [ "nextcloud" ];
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
}
