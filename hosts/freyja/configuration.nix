{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    # inputs.private.nixosModules."lif"

    ../_common/configuration.nix

    # ./bluetooth.nix
    ./bootloader.nix
    ./keys.nix
    ./bluetooth.nix
    ./pen.nix
    ./networking.nix

    ../../home/users/oq
    ../../home/users/root

    ../../modules/battery
    ../../modules/avahi
    ../../modules/home-manager
    ../../modules/hypr
    ../../modules/sops
    ../../modules/ydotool
    ../../modules/lid
    ../../modules/pam
  ];

  # temp? because of darkmode stuff
  # https://home-manager-options.extranix.com/?query=xdg.portal.enable&release=release-25.11
  environment.pathsToLink = ["/share/xdg-desktop-portal" "/share/applications"];

  modules = {
    # todo: replace this with an actual fix. (the wlan driver is fucked and prevents sleep/suspend)
    lid.disable = true;
    battery.enable = true;
    avahi.enable = true;
    hypr = {
      enable = true;
      defaultUser = "oq";
      lock.replaceLogin = false;
    };
    pam.enable = true;
    ydotool.enable = true;
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
      };

      themes.cogecha-1_uneasy-flowers.enable = false;
      themes.cogecha-2_oni.enable = true;

      modules = {
        input = {
          mouse = {
            speed = 0.1;
            accel = true;
          };
        };
        krita.enable = true;
        nixvim.wayland.enable = true;
        hypr.enable = true;
        browser = {
          firefox = {
            tor.enable = false;
            zen = {
              enable = true;
              setDefault = true;
              profiles = [
                "oq@zen"
              ];
            };
          };
        };
        zoom.enable = false;
        kooha.enable = false;
        jetbrains = {
          enable = false;
        };
        minecraft = {
          prismlauncher.enable = false;
        };
      };
      private = {
        secrets.ssh = {
          server = true;
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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
