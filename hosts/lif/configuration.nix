{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.private.nixosModules."lif"

    ../_common/configuration.nix

    ./bootloader.nix
    ./mount.nix
    ./bluetooth.nix
    ./glorious-model-o.nix
    ./packages.nix
    ./nvidia.nix
    ./intel.nix
    ./networking.nix

    ../../modules/hypr
    ../../modules/ydotool
    ../../modules/steam
    ../../modules/sops
    ../../modules/avahi
    ../../home/users/oq
    ../../home/users/root

    ../../modules/home-manager

    ../../modules/flake-upgrader
    ../../modules/nixpkgs-garbage-disposal
    ../../modules/wireguard
    ../../modules/wireguard/unicorns

    #todo: fix wireguard vpn
    # (import ../../modules/wireguard/template.nix {
    #   ip = "10.100.0.2/32";
    #   privateKeyFile = ./wireguard/0qln/private.key.secrets;
    #   serverAddress = "0qln.duckdns.org";
    #   serverPubKey = builtins.readFile ../lifbrasir/wireguard/0qln/public.key;
    #   vpnName = "0qln";
    # })
  ];

  modules = {
    wireguard.enable = true;
    avahi.enable = true;
    hypr.enable = true;
    steam.enable = true;
    ydotool.enable = true;
  };

  sops = {
    enable = true;
    # TODO: improve yubi key integration and use it.
    enableYubikeyIntegration = false;
    identities = [
      {
        name = "oq.age";
        file = "/home/oq/.config/sops/age/keys.txt";
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

  home-manager = {
    users.oq = _: {
      imports = [./vars.nix];
      settings = {
        enable = true;
        uiEnv = "gui";
        enableWorkSimple = true;
      };
      modules = {
        ssh.enableWorkSimple = true;
        browser = {
          firefox = {
            tor.enable = true;
            zen = {
              enable = true;
              setDefault = true;
            };
          };
        };
        zoom.enable = true;
        kooha.enable = true;
        jetbrains = {
          enable = true;
          tools = with pkgs.jetbrains; [
            rider
          ];
        };
        minecraft = {
          prismlauncher.enable = true;
        };
        shotcut.enable = true;
      };
      private = {
        secrets.ssh = {
          server = true;
          work = true;
          work-devops = true;
        };
      };
    };

    users.root = _: {
      settings = {
        enable = true;
        uiEnv = "gui";
      };
    };
  };

  private = {
    wireguard = {
      enable = true;
      unicorns = true;
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
}
