{
  inputs,
  config,
  lib,
  flake,
  ...
}:
with lib; let
  inherit (config.vars.hosts.lifbrasir) fqdns;
in {
  imports = [
    inputs.private.nixosModules."lifbrasir"
    flake.nixosModules."lichess-bot"

    ../_common/configuration.nix

    ./mount.nix
    ./keys.nix
    ./bootloader.nix
    ./networking.nix
  ];

  users = {
    root.enable = true;
  };

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
    home-manager.enable = true;

    lid = {
      enable = true;
      dontTurnOffWhenClosed = true;
    };

    battery.enable = true;

    nginx.enable = true;

    vaultwarden = {
      enable = true;
      fqdn = {
        dn = "vw.${fqdns.primary.dn}";
        acmeHost = fqdns.primary.dn;
      };
    };

    dynIp-updater = {
      duckdns = {
        enable = true;
        domains = ["0qln"];
      };
      afraid = {
        enable = false;
        domains = ["oq.404.mn"];
      };
      cloudflare = {
        enable = true;
      };
    };

    gitea = {
      enable = true;
      fqdn = {
        dn = "git.${fqdns.primary.dn}";
        acmeHost = fqdns.primary.dn;
      };
      anubis.enable = false;
    };

    immich = {
      enable = true;
      fqdn = {
        dn = "immich.${fqdns.primary.dn}";
        acmeHost = fqdns.primary.dn;
      };
    };

    postgresql = {
      enable = true;
    };

    mysql = {
      enable = true;
    };

    acme = {
      enable = true;
      certs = {
        "0qln.duckdns.org" = {
          registrar = "duckdns";
          duckdnsInfos.tokenFile = mkDefault (throw "should be configured in .private");
        };
        "07112025.xyz" = {
          registrar = "cloudflare";
          cloudflareInfos.tokenFile = mkDefault (throw "should be configured in .private");
        };
      };
    };

    docker = {
      serviceDataDir = "/mnt/store-1/services/docker";
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
    };

    obsidian-livesync = {
      enable = false;
      # admin page: fqdn/_utils/index.html
      couchdb = {fqdn = fqdns.primary.dn;};
    };

    wireguard-service = {
      enable = false;
      externalInterface = "wlo1";
    };

    nextcloud = {
      enable = true;
      storagePath = "/mnt/store-1/services/nextcloud";
      primaryFqdn = "nextcloud.${fqdns.primary.dn}";
      acmeHost = fqdns.primary.dn;
      localFqdns = [
        "lifbrasir"
        "192.168.178.50"
      ];
    };

    vikunja = {
      enable = true;
      serviceDataDir = "/mnt/store-1/services/vikunja";
      primaryFqdn = "vikunja.${fqdns.primary.dn}";
      acmeHost = fqdns.primary.dn;
    };

    lichess-bot = {
      enable = true;
      name = "nephrid";
      configFile = ./lichess-bot/config.yml;
    };
  };

  home-manager = {
    users.root = _: {
      home.file."lichess-bot/engines/nephrid".source = getExe inputs.nephrid.packages.x86_64-linux.nephrid-hce;
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
