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

    (import ../../services/obsidian-livesync {
      secrets-env = ./obsidian-livesync/secrets.couchdb.env;
    })

    ../../services/database

    (import ../../services/nextcloud {
      dbpassFile = ./nextcloud/secrets.dbpassFile;
      dbpassFileHashed = ./nextcloud/secrets.dbpassFile.hashed;
      adminpassFile = ./nextcloud/secrets.adminpassFile;
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
