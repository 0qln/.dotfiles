{...}: let
  fqdns = import ./fqdns.nix;
in {
  imports = [
    ../_common/configuration.nix

    ./mount.nix
    ./keys.nix
    ./bootloader.nix
    ./bat.nix
    ./lid.nix
    ./networking.nix

    ../../home/users/root/default.nix

    ../../modules/sops
    ../../modules/home-manager

    ../../services/ssh
    ../../services/dashboard

    ../../services/acme

    (import ../../services/todoist-backup {
      secrets-env = ./todoist-backup/secrets.env;
    })

    # https://couchdb.0qln.duckdns.org/_utils/index.html#
    (import ../../services/obsidian-livesync {
      secrets-env = ./obsidian-livesync/secrets.couchdb.env;
      fqdn = fqdns.primary;
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

    ../../services/postgresql
    ../../services/gitea
    ../../services/docker
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

  my-services = {
    gitea = {
      enable = true;
      primaryFqdn = "git.${fqdns.primary}";
      dbpassFile = ./gitea/secrets/dbpass;
    };
  };

  modules = {
    postgresql = {
      enable = true;
    };
    acme = {
      enable = true;
      duckdnsTokenFile = ./duckdns/secrets.token;
      certs.baseDn.name = fqdns.primary;
    };
    docker = {
      enable = false;
    };
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
      primaryFqdn = "nextcloud.${fqdns.primary}";
      secondaryFqdns = map (x: "nextcloud.${x}") fqdns.secondary;
      localFqdns = [
        "lifbrasir"
        "192.168.178.50"
      ];
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
