{ pkgs, inputs, ... }:
{
  imports = [
    ../_common/configuration.nix

    ./packages.nix
    ./mount.nix
    ./keys.nix
    ./bootloader.nix
    ./bat.nix
    ./lid.nix
    ./sops.nix

    ../../home/oq/users/root/default.tui.nix

    (import ../../modules/home-manager {
      extraArgs = { };
    })

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

    (import ../../services/wireguard {
      privateKeyFile = ./wireguard/0qln/private.key.secrets;
      externalInterface = "wlo1";
    })

    #TODO: these are intested for lifbrasir. test first then activate them.
    # (import ../../services/flake-upgrader {
    #   flakeDir = "/root/.dotfiles";
    # })
    #
    # (import ../../services/nixos-garbage-disposal {
    # })
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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
}
