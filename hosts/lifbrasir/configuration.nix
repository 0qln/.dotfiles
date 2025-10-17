{
  pkgs,
  inputs,
  ...
}: let
  fqdns = [
    "0qln.duckdns.org"
    "oq.404.mn"
  ];
in {
  imports = [
    ../_common/configuration.nix

    ./mount.nix
    ./keys.nix
    ./bootloader.nix
    ./bat.nix
    ./lid.nix
    ../../modules/sops

    ../../home/oq/users/root/default.tui.nix

    (import ../../modules/home-manager {
      extraArgs = {};
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

    ../../services/nextcloud

    (import ../../services/dynIp-updater/duckdns.nix {
      tokenFile = ./duckdns/secrets.token;
      domains = ["0qln"];
    })

    ../../services/dynIp-updater/afraid.nix

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

  sops = {
    enable = true;
    enableYubikeyIntegration = false;
    identities = [
      {
        name = "lifbrasir.age";
        file = "/root/.config/sops/age/keys.txt";
      }
    ];
    yubiIdentities = [
      rec {
        name = "yubi-1/age-yubikey-identity-ca0b293d.txt";
        file = ../../yubis/${name};
      }
      rec {
        name = "yubi-2/age-yubikey-identity-7432b76e.txt";
        file = ../../yubis/${name};
      }
    ];
  };

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

    dynIp-updater-afraid = {
      enable = true;
      credentialsFile = ./afraid/secrets.credentials.env;
      domains = ["oq.404.mn"];
    };

    my-nextcloud = {
      enable = true;
      dbpassFile = ./nextcloud/secrets.dbpassFile;
      dbpassFileHashed = ./nextcloud/secrets.dbpassFile.hashed;
      adminpassFile = ./nextcloud/secrets.adminpassFile;
      storagePath = "/mnt/store-1/services/nextcloud";
      primaryFqdn = "nextcloud.0qln.duckdns.org";
      secondaryFqdns = [
        "nextcloud.oq.404.mn"
        # "nextcloud.myaddr.dev" TODO
      ];
      localFqdns = [
        "lifbrasir"
        "192.168.178.50"
      ];
    };
  };

  networking.hosts = {
    # TODO: use dnsmasq with a local dns server instead
    # of specifying every subdomain maunally
    "127.0.0.1" = fqdns ++ map (x: "nextcloud.${x}") fqdns;
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
