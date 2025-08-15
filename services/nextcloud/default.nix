{
  adminpassFile,
  dbpassFile,
  dbpassFileHashed,
  fqdn,
  duckdnsTokenFile,
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
    ../acme
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

      "${serviceName}/duckdnsToken" = {
        sopsFile = duckdnsTokenFile;
        mode = "0400"; # TODO: set user:group and more restricted
        format = "binary";
      };
    };

    # TODO:
    # no idea why this does not work...
    # error is something about not being able to reach duckdns with UDP...
    # docs:
    # - https://go-acme.github.io/lego/dns/#configuration-and-credentials
    # - https://go-acme.github.io/lego/dns/duckdns/
    # - https://www.duckdns.org/spec.jsp
    #
    # security.acme = {
    #   certs."0qln.duckdns.org" = {
    #     dnsProvider = "duckdns";
    #     environmentFile = "${pkgs.writeText "duckdns-creds" ''
    #       DUCKDNS_TOKEN_FILE=${config.sops.secrets."${serviceName}/duckdnsToken".path}
    #     ''}";
    #   };
    # };

    services.nginx.virtualHosts.${fqdn} = {
      enableACME = true;
      forceSSL = true;
      # useACMEHost = "0qln.duckdns.org";
    };

    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud31;
      hostName = fqdn;
      home = storagePath;
      database.createLocally = false;
      enableImagemagick = true;
      https = true;
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
        trusted_domains = [
          "192.168.178.50"
          "lifbrasir"
          fqdn
        ];
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
