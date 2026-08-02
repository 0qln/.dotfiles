{
  config,
  flake,
  inputs,
  pkgs,
  ...
}: let
  theme = "foggy-forest-1";
in {
  imports = [
    ../_common/configuration.nix

    flake.nixosModules.sops
    flake.nixosModules.android
    flake.nixosModules.bluetooth
    flake.nixosModules.emojis
    flake.nixosModules.flatpak
    flake.nixosModules."themes/${theme}"
    flake.nixosModules.vscode

    ./bootloader.nix
    ./keys.nix
    ./pen.nix
    ./networking.nix
  ];

  users = {
    root.enable = true;
    oq.enable = true;
  };

  # The MediaTek MT7925 combo Wi-Fi/Bluetooth chip (USB 0e8d:8c38) fails to
  # initialize its Bluetooth controller ("Failed to send wmt func ctrl (-22)",
  # HW/SW Version 0x00000000, no controller in bluetoothctl/bluetui).
  # Root cause: upstream regression 634a4408c061 ("Bluetooth: btmtk: validate
  # WMT event SKB length before struct access"), present in our pinned kernel
  # (6.18.32), which wrongly rejects the status-less WMT FUNC_CTRL event this
  # chip sends. Fixed upstream by e3ac0d9f1a20 ("accept too short WMT FUNC_CTRL
  # events"), backported to linux-6.18.y and shipped in 6.18.34. Use the
  # prebuilt kernel from a newer nixpkgs (no local compilation).
  # see: https://bugzilla.kernel.org/show_bug.cgi?id=221521
  boot.kernelPackages =
    inputs.nixpkgs-freyja-kernel.legacyPackages.${pkgs.stdenv.hostPlatform.system}.linuxPackages;

  modules = {
    home-manager.enable = true;

    android = {
      enable = true;
      android-studio.enable = false; # todo: download when good internet
      users = ["oq"];
    };

    vscode.enable = true;

    bluetooth.enable = true;

    emojis.enable = true;

    flatpak.enable = true;

    lid = {
      enable = true;
      # todo: replace this with an actual fix. (the wlan driver is fucked and prevents sleep/suspend)
      dontTurnOffWhenClosed = true;
    };
    battery.enable = !config.modules.kde.enable;
    avahi.enable = true;
    hyprlock = {
      defaultUser = "oq";
      replaceLogin = false;
    };

    # enable kde x11 sessions aswell, since the hp stylus pen's configuration via wacom
    # drivers and libwacom in not supported under wayland.
    # see:
    # - https://github.com/linuxwacom/xf86-input-wacom/wiki/Wayland
    # also relevant:
    # - https://knowledgebase.frame.work/en_us/stylus-setup-and-troubleshooting-on-linux-B1J5djrSbx
    # - https://github.com/linuxwacom/input-wacom/wiki/Common-Issues
    # - https://bugs.kde.org/show_bug.cgi?id=469232
    # - https://forums.linuxmint.com/viewtopic.php?t=444949
    kde = {
      enable = true;
      compositor = "x11";
    };
    pam.enable = true;
    ydotool.enable = true;
    xdg.enable = true;
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

  themes = {
    ${theme}.enable = true;
  };

  home-manager = {
    users.oq = _: {
      imports = [
        ./home-vars.nix
        flake.homeModules."themes/${theme}"
        flake.homeModules.flatpak
        flake.homeModules.vscode
      ];
      settings = {
        enable = true;
        uiEnv = "gui";
      };

      # todo: is this still needed?
      # themes.cogecha-1_uneasy-flowers.enable = false;
      # todo: is this still needed?
      # themes.cogecha-2_oni.enable = false;

      themes.${theme}.enable = true;

      modules = {
        input = {
          mouse = {
            speed = 0.1;
            accel = true;
          };
        };

        flatpak.enable = true;
        vscode.enable = true;

        krita.enable = true;
        nixvim.wayland.enable = true;
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
