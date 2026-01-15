{
  config,
  lib,
  ...
}: let
  monitors = config.vars.monitors;
  cfg = config.modules.hypr.land;
  fmtColor = config.utils.fmtColor_rgbaFn;
  fmtMonitor = config.utils.fmtMonitor_device;
in
  with lib; {
    options.modules.hypr.land = {
      enable = config.utils.mkEnableOption "hypr.land" config.modules.hypr.enable;
    };

    imports = [
      ./input.nix
      ./modules.nix
    ];

    config = mkIf cfg.enable {
      wayland.windowManager.hyprland.enable = true;
      wayland.windowManager.hyprland.settings = {
        # =============== COLORS ===============
        # source = "${config.xdg.cache}/pywal/colors-hyprland.conf";

        monitor =
          lib.attrsets.mapAttrsToList
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
          pseudotile = true;
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
              "monitor ${monitors.devices.left.name}, tag:music"
              "monitor ${monitors.devices.left.name}, tag:zoom"
            ];
          };
        in
          mkMerge [
            mapping.${monitors.arrangement.byPictogram}
            [
              "float, title:todoist-quick-add"

              "float, title:Open Files"
              "center, title:Open Files"

              "tag +music, title:(?i).*youtube[-_ ]?music.*"
              "size 918 536, tag:music"
              "pseudo, tag:music"

              # chromium popups
              "tag +chromium_popup, title: about:blank - Chromium"
              "float, tag:chromium_popup"
              "center, tag:chromium_popup"
              "size 900 900, tag:chromium_popup"

              # image windows
              "tag +qimgv, class:qimgv"
              "float, tag:qimgv"
              "center, tag:qimgv"
              "size 900 900, tag:qimgv"

              # dialogs
              "tag +dialog, class:code, title:Open File"
              "float, tag:dialog"
              "center, tag:dialog"
              "size 900 900, tag:dialog"

              # zoom
              "tag +zoom, class:zoom"
              "float, tag:zoom"

              # no animations
              "tag +no-anim, class:ueberzug.*"
              "noanim, tag:no-anim"

              # move ueberzug windows off the screen so they don't
              # flicker in the center until ueberzug moves them.
              "move -10000 -10000, initialClass:ueberzug.*"
            ]
          ];
        # windowrule = [
        #   "float,class:^(kitty)$,title:^(kitty)$"
        #   "suppressevent maximize, class:.*"
        #   "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
        # ];
      };
    };
  }
