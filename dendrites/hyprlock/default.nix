{inputs, ...}: {
  flake.nixosModules.hyprlock = {
    lib,
    config,
    ...
  }:
    with lib; let
      cfg = config.modules.hyprlock;
    in {
      options.modules.hyprlock = {
        enable = mkOption {
          description = "Whether to enable hyprlock.";
          type = types.bool;
          default = true;
        };

        # if you use this, gnome-keyring will not unlock automatically on login.
        # todo: find a solution for that.
        replaceLogin = mkOption {
          description = "Whether to replace the login screen with hyprlock.";
          type = types.bool;
          default = true;
        };

        defaultUser = mkOption {
          type = types.str;
          description = "The default user.";
        };
      };

      config = mkIf cfg.enable {
        # https://home-manager-options.extranix.com/?query=programs.hyprlock.enable&release=release-25.11
        security.pam.services.hyprlock = {
          enableGnomeKeyring = true;
        };

        services.displayManager.sddm = {
          settings = mkIf cfg.replaceLogin {
            Autologin = {
              Session = "hyprland";
              User = cfg.defaultUser;
            };
          };
        };

        home-manager = mkIf cfg.replaceLogin {
          users.${cfg.defaultUser} = _: {
            modules.hyprlock.autostart = true;
          };
        };
      };
    };

  flake.homeModules.hyprlock = {
    config,
    lib,
    ...
  }:
    with lib; let
      cfg = config.modules.hyprlock;
    in {
      options.modules.hyprlock = {
        enable = mkEnableOption "hyprlock";
        autostart = mkEnableOption "automatically execute on startup";
      };

      config = let
        inherit (config.modules.hyprland.input) mainMod;
        inherit (config.vars) monitors;
      in
        mkIf cfg.enable {
          # https://home-manager-options.extranix.com/?query=programs.hyprlock.enable&release=release-25.11
          programs.hyprlock = {
            enable = true;
            settings = {
              background = mkDefault [
                {
                  path = "screenshot";
                  blur_passes = 3;
                  blur_size = 8;
                }
              ];

              input-field = mkDefault [
                {
                  fade_on_empty = false;
                  monitor = monitors.devices.center.name;
                }
              ];
            };
          };

          wayland.windowManager.hyprland = {
            settings = {
              bind = mkMerge [
                [
                  "${mainMod}, L, exec, hyprlock"
                ]
              ];

              exec-once = mkMerge [
                (mkIf cfg.autostart ["hyprlock || hyprctl dispatch exit"])
              ];
            };
          };
        };
    };
}
