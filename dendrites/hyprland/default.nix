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
    fmtMonitor = config.utils.fmtMonitor_lua;
  in {
    imports = [
      ./input.nix

      self.homeModules.hyprland-mods
    ];

    config = mkIf cfg.enable {
      wayland.windowManager.hyprland.configType = "lua";
      wayland.windowManager.hyprland.enable = true;
      wayland.windowManager.hyprland.settings = {
        # =============== COLORS ===============
        # source = "${config.xdg.cache}/pywal/colors-hyprland.conf";

        monitor =
          attrsets.mapAttrsToList
          (n: v: fmtMonitor n v monitors.arrangement.byName.${v.name})
          monitors.devices;

        workspace_rule = let
          # don't forget to set defaults, otherwise the monitor assignments won't work:
          # https://github.com/hyprwm/Hyprland/issues/2331
          c = monitors.devices.center.name;
          l = monitors.devices.left.name;
          r = monitors.devices.right.name;
          mapping = {
            "-" = [
              {workspace = "1"; monitor = c; default = true;}
              {workspace = "2"; monitor = c;}
              {workspace = "3"; monitor = c;}
              {workspace = "4"; monitor = c;}
              {workspace = "5"; monitor = c;}
              {workspace = "6"; monitor = c;}
              {workspace = "7"; monitor = c;}
              {workspace = "8"; monitor = c;}
              {workspace = "9"; monitor = c;}
              {workspace = "0"; monitor = c;}
            ];
            "|-|" = [
              {workspace = "1"; monitor = c; default = true;}
              {workspace = "2"; monitor = c;}
              {workspace = "3"; monitor = c;}
              {workspace = "4"; monitor = c;}
              {workspace = "5"; monitor = c;}

              {workspace = "6"; monitor = l; default = true;}
              {workspace = "6"; layout_opts = {orientation = "bottom";};}
              {workspace = "7"; monitor = l;}
              {workspace = "7"; layout_opts = {orientation = "bottom";};}

              {workspace = "8"; monitor = r; default = true;}
              {workspace = "8"; layout_opts = {orientation = "bottom";};}
              {workspace = "9"; monitor = r;}
              {workspace = "9"; layout_opts = {orientation = "bottom";};}
            ];
          };
        in
          mapping.${monitors.arrangement.byPictogram};

        config = {
          general = with config.theme.win; {
            inherit
              (layout)
              gaps_in
              gaps_out
              ;

            border_size = border.size;

            col = {
              active_border = fmtColor border.active;
              inactive_border = fmtColor border.inactive;
            };

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

          animations.enabled = true;

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
        };

        # https://easings.net/
        # https://www.cssportal.com/css-cubic-bezier-generator/
        curve = [
          {_args = ["easeOutQuint" {type = "bezier"; points = [[0.23 1] [0.32 1]];}];}
          {_args = ["easeInOutCubic" {type = "bezier"; points = [[0.65 0.05] [0.36 1]];}];}
          {_args = ["easeOutSine" {type = "bezier"; points = [[0.61 1] [0.88 1]];}];}
          {_args = ["linear" {type = "bezier"; points = [[0 0] [1 1]];}];}
          {_args = ["almostLinear" {type = "bezier"; points = [[0.5 0.5] [0.75 1.0]];}];}
          {_args = ["quick" {type = "bezier"; points = [[0.15 0] [0.1 1]];}];}
        ];

        animation = [
          {leaf = "global"; enabled = true; speed = 10; bezier = "default";}
          {leaf = "border"; enabled = true; speed = 5.39; bezier = "easeOutQuint";}
          {leaf = "windows"; enabled = true; speed = 4.79; bezier = "easeOutQuint";}
          {leaf = "windowsIn"; enabled = true; speed = 4.1; bezier = "easeOutQuint"; style = "popin 87%";}
          {leaf = "windowsOut"; enabled = true; speed = 1.49; bezier = "linear"; style = "popin 87%";}
          {leaf = "fadeIn"; enabled = true; speed = 1.73; bezier = "almostLinear";}
          {leaf = "fadeOut"; enabled = true; speed = 1.46; bezier = "almostLinear";}
          {leaf = "fadeShadow"; enabled = true; speed = 2.00; bezier = "easeOutSine";}
          {leaf = "fade"; enabled = true; speed = 3.03; bezier = "quick";}
          {leaf = "layers"; enabled = true; speed = 3.81; bezier = "easeOutQuint";}
          {leaf = "layersIn"; enabled = true; speed = 4; bezier = "easeOutQuint"; style = "fade";}
          {leaf = "layersOut"; enabled = true; speed = 1.5; bezier = "linear"; style = "fade";}
          {leaf = "fadeLayersIn"; enabled = true; speed = 1.79; bezier = "almostLinear";}
          {leaf = "fadeLayersOut"; enabled = true; speed = 1.39; bezier = "almostLinear";}
          {leaf = "workspaces"; enabled = true; speed = 1.94; bezier = "almostLinear"; style = "fade";}
          {leaf = "workspacesIn"; enabled = true; speed = 1.21; bezier = "almostLinear"; style = "fade";}
          {leaf = "workspacesOut"; enabled = true; speed = 1.94; bezier = "almostLinear"; style = "fade";}
        ];

        # ============== WINDOW RULES ==============
        window_rule = let
          mapping = {
            "-" = [];
            "|-|" = [
              {match = {tag = "music";}; monitor = monitors.devices.left.name;}
              {match = {tag = "zoom";}; monitor = monitors.devices.left.name;}
            ];
          };
        in
          mkMerge [
            mapping.${monitors.arrangement.byPictogram}
            [
              {match = {title = "todoist-quick-add";}; float = true;}

              {match = {title = "Open Files";}; float = true; center = true;}

              {match = {title = "(?i).*youtube[-_ ]?music.*";}; tag = "+music";}
              {match = {tag = "music";}; size = [918 536]; pseudo = true;}

              # chromium popups
              {match = {title = "about:blank - Chromium";}; tag = "+chromium_popup";}
              {match = {tag = "chromium_popup";}; float = true; center = true; size = [900 900];}

              # image windows
              {match = {class = "qimgv";}; tag = "+qimgv";}
              {match = {tag = "qimgv";}; float = true; center = true; size = [900 900];}

              # dialogs
              {match = {title = "Open File"; class = "code";}; tag = "+dialog";}
              {match = {tag = "dialog";}; float = true; center = true; size = [900 900];}

              # zoom
              {match = {class = "zoom";}; tag = "+zoom";}
              {match = {tag = "zoom";}; float = true;}

              # no animations
              {match = {class = "ueberzug.*";}; tag = "+tool";}
              {match = {tag = "tool";}; no_anim = true; float = true;}

              # move ueberzug windows off the screen so they don't
              # flicker in the center until ueberzug moves them.
              {match = {class = "ueberzug.*";}; move = [(-10000) (-10000)];}
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
