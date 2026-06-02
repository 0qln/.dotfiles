{
  inputs,
  self,
  ...
}:
with inputs.nixpkgs.lib; {
  imports = [
    ./mods.nix
  ];

  flake.nixosModules.hyprland = {
    config,
    pkgs,
    inputs,
    ...
  }: let
    cfg = config.modules.hyprland;
  in {
    config = mkIf cfg.enable {
      modules.nix.caches = {"hyprland.cachix.org" = "a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=";};

      # You can disable this if you're only using the Wayland session.
      # (Using lower priority since this is not a *requirement* and should be easily overridable
      # by other modules, such as ../kde)
      services.xserver.enable = mkDefault false;

      # Logins screen
      services.displayManager.sddm = {
        wayland.enable = true;
        enable = true;
      };

      environment.systemPackages = with pkgs; [
        kitty # required for the default Hyprland config
        playerctl
        brightnessctl
        wl-clipboard-rs
        inputs.hyprpaper.packages.${pkgs.stdenv.hostPlatform.system}.hyprpaper
        libnotify
      ];
      programs.hyprland = {
        enable = true;
        # set the flake package
        package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
        # make sure to also set the portal package, so that they are in sync
        portalPackage =
          inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      };
      environment.sessionVariables.NIXOS_OZONE_WL = "1";

      # rtkit (optional, recommended) allows Pipewire to use the realtime scheduler for increased performance.
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true; # if not already enabled
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        # If you want to use JACK applications, uncomment the following
        #jack.enable = true;

        # use the example session manager (no others are packaged yet so this is enabled by default,
        # no need to redefine it in your config for now)
        #media-session.enable = true;
      };

      # Enable touchpad support (enabled default in most desktopManager).
      # services.xserver.libinput.enable = true;

      services.pipewire.wireplumber = {
        enable = true;
      };
    };
  };

  flake.homeModules.hyprland = {config, ...}: let
    monitors = config.vars.monitors;
    cfg = config.modules.hyprland;
    fmtColor = config.utils.fmtColor_rgbaFn;
    fmtMonitor = config.utils.fmtMonitor_device;
  in {
    imports = [
      ./input.nix

      self.homeModules.hyprland-mods
    ];

    config = mkIf cfg.enable {
      wayland.windowManager.hyprland.configType = "hyprlang";
      wayland.windowManager.hyprland.enable = true;
      wayland.windowManager.hyprland.settings = {
        # =============== COLORS ===============
        # source = "${config.xdg.cache}/pywal/colors-hyprland.conf";

        monitor =
          attrsets.mapAttrsToList
          (n: v: fmtMonitor n v monitors.arrangement.byName.${v.name})
          monitors.devices;

        workspace = let
          # don't forget to set defaults, otherwise the monitor assignments won't work:
          # https://github.com/hyprwm/Hyprland/issues/2331
          mapping = {
            "-" = [
              "1, monitor:${monitors.devices.center.name}, default:true"
              "2, monitor:${monitors.devices.center.name}"
              "3, monitor:${monitors.devices.center.name}"
              "4, monitor:${monitors.devices.center.name}"
              "5, monitor:${monitors.devices.center.name}"
              "6, monitor:${monitors.devices.center.name}"
              "7, monitor:${monitors.devices.center.name}"
              "8, monitor:${monitors.devices.center.name}"
              "9, monitor:${monitors.devices.center.name}"
              "0, monitor:${monitors.devices.center.name}"
            ];
            "|-|" = [
              "1, monitor:${monitors.devices.center.name}, default:true"
              "2, monitor:${monitors.devices.center.name}"
              "3, monitor:${monitors.devices.center.name}"
              "4, monitor:${monitors.devices.center.name}"
              "5, monitor:${monitors.devices.center.name}"

              "6, monitor:${monitors.devices.left.name}, default:true"
              "6, layoutopt:orientation:bottom"
              "7, monitor:${monitors.devices.left.name}"
              "7, layoutopt:orientation:bottom"

              "8, monitor:${monitors.devices.right.name}, default:true"
              "8, layoutopt:orientation:bottom"
              "9, monitor:${monitors.devices.right.name}"
              "9, layoutopt:orientation:bottom"
            ];
          };
        in
          mapping.${monitors.arrangement.byPictogram};

        general = with config.theme.win; {
          inherit
            (layout)
            gaps_in
            gaps_out
            ;

          border_size = border.size;

          "col.active_border" = fmtColor border.active;
          "col.inactive_border" = fmtColor border.inactive;

          resize_on_border = true;

          allow_tearing = false;

          layout = "master";
        };

        decoration = {
          inherit (config.theme.win.corners) rounding rounding_power;

          blur = {enabled = true;} // config.theme.win.blur;

          active_opacity = config.theme.win.opacity.active;
          inactive_opacity = config.theme.win.opacity.inactive;

          shadow = {
            enabled = true;
            color = fmtColor config.theme.win.shadow.active;
            color_inactive = fmtColor config.theme.win.shadow.inactive;
            inherit (config.theme.win.shadow) range render_power;
          };
        };

        cursor = {
          hide_on_key_press = true;
          no_warps = true;
        };

        animations = {
          enabled = true;
          bezier = [
            # https://easings.net/
            # https://www.cssportal.com/css-cubic-bezier-generator/
            "easeOutQuint,0.23,1,0.32,1"
            "easeInOutCubic,0.65,0.05,0.36,1"
            "easeOutSine,0.61,1,0.88,1"
            "linear,0,0,1,1"
            "almostLinear,0.5,0.5,0.75,1.0"
            "quick,0.15,0,0.1,1"
          ];
          animation = [
            "global, 1, 10, default"
            "border, 1, 5.39, easeOutQuint"
            "windows, 1, 4.79, easeOutQuint"
            "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
            "windowsOut, 1, 1.49, linear, popin 87%"
            "fadeIn, 1, 1.73, almostLinear"
            "fadeOut, 1, 1.46, almostLinear"
            "fadeShadow, 1, 2.00, easeOutSine"
            "fade, 1, 3.03, quick"
            "layers, 1, 3.81, easeOutQuint"
            "layersIn, 1, 4, easeOutQuint, fade"
            "layersOut, 1, 1.5, linear, fade"
            "fadeLayersIn, 1, 1.79, almostLinear"
            "fadeLayersOut, 1, 1.39, almostLinear"
            "workspaces, 1, 1.94, almostLinear, fade"
            "workspacesIn, 1, 1.21, almostLinear, fade"
            "workspacesOut, 1, 1.94, almostLinear, fade"
          ];
        };

        # ============== LAYOUTS ==============
        dwindle = {
          preserve_split = true;
        };

        master = {
          new_on_top = true;
          new_status = "slave";
        };

        misc = {
          force_default_wallpaper = 0;
          disable_hyprland_logo = false;
        };

        # ============== WINDOW RULES ==============
        windowrule = let
          mapping = {
            "-" = [];
            "|-|" = [
              "match:tag music, monitor ${monitors.devices.left.name}, "
              "match:tag zoom, monitor ${monitors.devices.left.name}"
            ];
          };
        in
          mkMerge [
            mapping.${monitors.arrangement.byPictogram}
            [
              "match:title todoist-quick-add, float 1"

              "match:title Open Files, float 1"
              "match:title Open Files, center 1"

              "match:title (?i).*youtube[-_ ]?music.*, tag +music"
              "match:tag music, size 918 536"
              "match:tag music, pseudo 1"

              # chromium popups
              "match:title about:blank - Chromium, tag +chromium_popup"
              "match:tag chromium_popup, float 1"
              "match:tag chromium_popup, center 1"
              "match:tag chromium_popup, size 900 900"

              # image windows
              "match:class qimgv, tag +qimgv"
              "match:tag qimgv, float 1"
              "match:tag qimgv, center 1"
              "match:tag qimgv, size 900 900"

              # dialogs
              "match:title Open File, match:class code, tag +dialog"
              "match:tag dialog, float 1"
              "match:tag dialog, center 1"
              "match:tag dialog, size 900 900"

              # zoom
              "match:class zoom, tag +zoom"
              "match:tag zoom, float 1"

              # no animations
              "match:class ueberzug.*, tag +tool"
              "match:tag tool, no_anim 1"
              "match:tag tool, float 1"

              # move ueberzug windows off the screen so they don't
              # flicker in the center until ueberzug moves them.
              "match:class ueberzug.*, move -10000 -10000"
            ]
          ];
        # windowrule = [
        #   "float,class:^(kitty)$,title:^(kitty)$"
        #   "suppressevent maximize, class:.*"
        #   "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
        # ];
      };
    };
  };
}
