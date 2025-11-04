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
    ../../modules/ssh/service.nix
    ../../modules/dashboard
    ../../modules/acme
    ../../modules/ssh
    ../../modules/todoist-backup
    ../../modules/obsidian-livesync
    ../../modules/nextcloud
    ../../modules/dynIp-updater/duckdns.nix
    ../../modules/dynIp-updater/afraid.nix
    ../../modules/wireguard/service.nix
    ../../modules/postgresql
    ../../modules/gitea
    ../../modules/docker
    ../../modules/mysql
    ../../modules/obsidian-livesync
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

  modules = {
    dynIp-updater = {
      duckdns = {
        enable = true;
        tokenFile = ./duckdns/secrets.token;
        domains = ["0qln"];
      };
      afraid = {
        enable = false;
        credentialsFile = ./afraid/secrets.credentials.env;
        domains = ["oq.404.mn"];
      };
    };
    gitea = {
      enable = true;
      primaryFqdn = "git.${fqdns.primary}";
      dbpassFile = ./gitea/secrets/dbpass;
    };

    postgresql = {
      enable = true;
    };

    mysql = {
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

    avahi = {
      enable = true;
    };

    dashboard = {
      enable = true;
    };

    ssh-service = {
      enable = true;
      keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHGSLpGhb4X7V6eDVqXq9uzUth9xfHJsSugmOZzS+qt1 user@Linus-PC"
      ];
    };

    todoist-backup = {
      enable = true;
      secretsEnvFile = ./todoist-backup/secrets.env;
    };

    obsidian-livesync = {
      enable = false;
      # admin page: https://couchdb.0qln.duckdns.org/_utils/index.html#
      couchdb = {
        fqdn = fqdns.primary;
        secretsEnvFile = ./obsidian-livesync/secrets.couchdb.env;
        configFile = ./obsidian-livesync/secrets.couchdb.local-ini;
      };
    };

    wireguard-service = {
      enable = false;
      privateKeyFile = ./wireguard/0qln/private.key.secrets;
      externalInterface = "wlo1";
    };

    nextcloud = {
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
