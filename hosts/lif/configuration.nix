{
  pkgs,
  inputs,
  lib,
  ...
}:
with lib; {
  imports = [
    inputs.private.nixosModules."lif"

    ../_common/configuration.nix

    ./bluetooth.nix
    ./bootloader.nix
    ./glorious-model-o.nix
    ./intel.nix
    ./mount.nix
    ./networking.nix
    ./nvidia.nix

    # todo: fix wireguard vpn
    # (import ../../modules/wireguard/template.nix {
    #   ip = "10.100.0.2/32";
    #   privateKeyFile = ./wireguard/0qln/private.key.secrets;
    #   serverAddress = config.vars.fqdns.primary.dn;
    #   serverPubKey = builtins.readFile ../lifbrasir/wireguard/0qln/public.key;
    #   vpnName = "0qln";
    # })
  ];

  # todo: add this to other hosts
  users = {
    root.enable = true;
    oq.enable = true;
  };

  modules = {
    home-manager.enable = true;
    wireguard.enable = true;
    avahi.enable = true;
    hypr = {
      enable = true;
      defaultUser = "oq";
      lock.replaceLogin = false;
    };
    pam.enable = true;
    steam.enable = true;
    ydotool.enable = true;
    xdg.enable = true;

    docker = {
      enable = true;
      rootless.enable = true;
    };
  };

  sops = {
    enable = true;
    # todo: improve yubi key integration and use it.
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
      imports = [./home-vars.nix];
      settings = {
        enable = true;
        uiEnv = "gui";
        enableWorkSimple = true;
      };

      themes.cogecha-1_uneasy-flowers.enable = true;

      modules = {
        nixvim.wayland.enable = true;
        hypr.enable = true;
        browser = {
          firefox = {
            tor.enable = true;
            zen = {
              enable = true;
              setDefault = true;
              profiles = [
                "Default (Windows)"
                "[DEV] my-internet@zen"
              ];
            };
          };
        };
        zoom.enable = true;
        kooha.enable = true;
        jetbrains = {
          enable = true;
          tools = mkMerge [
            (with pkgs.jetbrains; [
              # rider
            ])
            (with pkgs; [
              jetbrains-toolbox
            ])
          ];
        };
        minecraft = {
          prismlauncher.enable = true;
        };
        shotcut.enable = true;
        tools.worksimple.enable = true;
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
      unicorns.enable = true;
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
