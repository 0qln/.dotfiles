{ pkgs, inputs, ... }:
{
  imports = [
    ../_common

    ./packages.nix
    ./mount.nix
    ./keys.nix
    ./bootloader.nix
    ./bat.nix
    ./lid.nix
    ./sops.nix

    ../../users/oq/default.tui.nix

    ../../services/ssh
    ../../services/dashboard

    (import ../../services/todoist-backup {
      secrets-env = ./todoist-backup/secrets.env;
    })

    # https://couchdb.0qln.duckdns.org/_utils/index.html#
    (import ../../services/obsidian-livesync {
      secrets-env = ./obsidian-livesync/secrets.couchdb.env;
      fqdn = "0qln.duckdns.org";
      configFilePath = ./obsidian-livesync/secrets.couchdb.local-ini;
    })

    # https://nextcloud.0qln.duckdns.org
    (import ../../services/nextcloud {
      dbpassFile = ./nextcloud/secrets.dbpassFile;
      dbpassFileHashed = ./nextcloud/secrets.dbpassFile.hashed;
      adminpassFile = ./nextcloud/secrets.adminpassFile;
      fqdn = "0qln.duckdns.org";
      duckdnsTokenFile = ./duckdns/secrets.token;
    })

    (import ../../services/dynIp-updater-duckdns {
      tokenFile = ./duckdns/secrets.token;
      domains = [ "0qln" ];
    })
  ];

  services = {

    todoist-backup = {
      enable = true;
    };

    dashboard = {
      enable = true;
    };

    obsidian-livesync = {
      enable = true;
    };

  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
}
