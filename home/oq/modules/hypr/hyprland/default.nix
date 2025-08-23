{
  config,
  pkgs,
  monitors,
  ...
}:
{
  imports = [
    ./input.nix
  ];

  wayland.windowManager.hyprland.enable = true;
  wayland.windowManager.hyprland.settings = {
    # =============== COLORS ===============
    # source = "${config.xdg.cache}/pywal/colors-hyprland.conf";

    # ============== VARIABLES ==============
    "$monL" = monitors.left;
    "$monR" = monitors.right;
    "$monC" = monitors.center;

    monitor = [
      "$monC, 1920x1080@60Hz, 0x550, 1, transform, 0"
      "$monR, 1920x1080@60Hz, 1920x0, 1, transform, 1"
      "$monL, 1920x1080@60Hz, -1080x0, 1, transform, 3"
    ];

    # =============== OTHER APPS ==============
    exec-once = [
      "waybar"
    ];

    workspace = [
      # don't forget to set defaults, otherwise the monitor assignments won't work:
      # https://github.com/hyprwm/Hyprland/issues/2331
      "1, monitor:$monC, default:true"
      "2, monitor:$monC"
      "3, monitor:$monC"
      #TODO: trying to get the window of the special workspace not to follow the mouse cursor, does not work yet
      "s[true], monitor:$monC"

      "4, monitor:$monL, default:true"
      "4, layoutopt:orientation:bottom"
      "5, monitor:$monL"
      "5, layoutopt:orientation:bottom"
      "6, monitor:$monL"
      "6, layoutopt:orientation:bottom"

      "7, monitor:$monR, default:true"
      "7, layoutopt:orientation:bottom"
      "8, monitor:$monR"
      "8, layoutopt:orientation:bottom"
      "9, monitor:$monR"
      "9, layoutopt:orientation:bottom"
    ];

    general = {
      gaps_in = 10;
      gaps_out = 20;
      border_size = 1;
      "col.active_border" = "rgba(ff000099) rgba(ffffffee) 45deg";
      "col.inactive_border" = "rgba(ffffffee) rgba(ff000099) 45deg";
      resize_on_border = true;
      allow_tearing = false;
      layout = "master";
    };

    decoration = {
      rounding = 0;
      rounding_power = 2;
      active_opacity = 1.0;
      inactive_opacity = 1.0;
      shadow = {
        enabled = false;
        range = 4;
        render_power = 3;
        color = "rgba(1a1a1aee)";
      };
      blur = {
        enabled = true;
        size = 5;
        passes = 1;
        vibrancy = 0.5696;
      };
    };

    animations = {
      enabled = true;
      bezier = [
        "easeOutQuint,0.23,1,0.32,1"
        "easeInOutCubic,0.65,0.05,0.36,1"
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
      force_default_wallpaper = -1;
      disable_hyprland_logo = false;
    };

    # ============== WINDOW RULES ==============
    windowrule = [

      "float, title:todoist-quick-add"

      "float, title:Open Files"
      "center, title:Open Files"

      "tag +music, title:(?i).*youtube[-_ ]?music.*"
      "size 918 536, tag:music"
      "pseudo, tag:music"
      "monitor ${monitors.left}, tag:music"

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
    ];
    # windowrule = [
    #   "float,class:^(kitty)$,title:^(kitty)$"
    #   "suppressevent maximize, class:.*"
    #   "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
    # ];
  };
}
