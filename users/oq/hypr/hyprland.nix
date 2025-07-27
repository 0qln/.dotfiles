{ options, ... }:
let
  
in {

  wayland.windowManager.hyprland.plugins = [
    
  ];
  wayland.windowManager.hyprland.settings = {
      # ============== VARIABLES ==============
      "$mainMod" = "SUPER";
      "$terminal" = "kitty";
      "$fileManager" = "lf";
      "$menu" = "wofi --show drun";

      "$monL" = "DP-4";
      "$monR" = "DP-3";
      "$monC" = "HDMI-A-1";

      monitor = [
        "$monC, 1920x1080@60Hz, 0x550, 1, transform, 0"
        "$monR, 1920x1080@60Hz, 1920x0, 1, transform, 1"
        "$monL, 1920x1080@60Hz, -1080x0, 1, transform, 3"
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
        "5, monitor:$monL"
        "6, monitor:$monL"

        "7, monitor:$monR, default:true"
        "8, monitor:$monR"
        "9, monitor:$monR"
      ];

      # For some reason hardware_cursors draws the cursor like 250px
      # to the left and some other issues...
      # fix source: https://github.com/hyprwm/Hyprland/issues/8852
      cursor = {
        no_hardware_cursors = "true";
      };

      general = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        resize_on_border = true;
        allow_tearing = false;
        layout = "dwindle";
      };

      decoration = {
        rounding = 10;
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
          size = 3;
          passes = 1;
          vibrancy = 0.1696;
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
        new_status = "master";
      };

      misc = {
        force_default_wallpaper = -1;
        disable_hyprland_logo = false;
      };


      # ============== INPUT ==============
      input = {
        kb_layout = "us";
        follow_mouse = 1;
        sensitivity = 0;
        touchpad = {
          natural_scroll = false;
        };
      };

      gestures = {
        workspace_swipe = false;
      };

      device = {
        name = "epic-mouse-v1";
        sensitivity = -0.5;
      };

      bind = [
        # Application shortcuts
        "$mainMod, Q, exec, $terminal"
        "$mainMod, C, killactive"
        "$mainMod, M, exit"
        "$mainMod, E, exec, $fileManager"
        "$mainMod, V, togglefloating"
        "$mainMod, R, exec, $menu"
        "$mainMod, P, pseudo"
        "$mainMod, J, togglesplit"
        "$mainMod, O, exec, obsidian"
        "$mainMod, F, exec, firefox"
        "$mainMod, Z, exec, zen"
        #TODO: either replace with zen instance with todoist, or inject transparency css...
        "$mainMod, T, exec, todoist-electron"

        # Focus movement
        "ALT SHIFT, h, movefocus, l"
        "ALT SHIFT, l, movefocus, r"
        "ALT SHIFT, k, movefocus, u"
        "ALT SHIFT, j, movefocus, d"

        # Workspace navigation
        "ALT SHIFT, 1, workspace, 1"
        "ALT SHIFT, 2, workspace, 2"
        "ALT SHIFT, 3, workspace, 3"
        "ALT SHIFT, 4, workspace, 4"
        "ALT SHIFT, 5, workspace, 5"
        "ALT SHIFT, 6, workspace, 6"
        "ALT SHIFT, 7, workspace, 7"
        "ALT SHIFT, 8, workspace, 8"
        "ALT SHIFT, 9, workspace, 9"
        "ALT SHIFT, 0, workspace, 10"

        # Move windows to workspaces
        "CTRL ALT, 1, movetoworkspace, 1"
        "CTRL ALT, 2, movetoworkspace, 2"
        "CTRL ALT, 3, movetoworkspace, 3"
        "CTRL ALT, 4, movetoworkspace, 4"
        "CTRL ALT, 5, movetoworkspace, 5"
        "CTRL ALT, 6, movetoworkspace, 6"
        "CTRL ALT, 7, movetoworkspace, 7"
        "CTRL ALT, 8, movetoworkspace, 8"
        "CTRL ALT, 9, movetoworkspace, 9"
        "CTRL ALT, 0, movetoworkspace, 10"

        # Special workspace
        "ALT SHIFT, S, togglespecialworkspace, magic"
        "CTRL ALT, S, movetoworkspace, special:magic"

        # Multimedia keys
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ", XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"
      ];

      # Mouse bindings
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      # ============== WINDOW RULES ==============
      # windowrule = [
      #   "float,class:^(kitty)$,title:^(kitty)$"
      #   "suppressevent maximize, class:.*"
      #   "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
      # ];
  };
}
