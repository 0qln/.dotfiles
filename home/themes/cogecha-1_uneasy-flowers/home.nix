{
  config,
  pkgs,
  lib,
  flake,
  inputs,
  ...
}:
with lib; let
  name = import ./name.nix;
  cfg = config.themes.${name};
  inherit (config.vars) monitors;
in {
  config = mkIf cfg.enable {
    modules = {
      #TODO: zen background rgba(45,53,59,0.7)

      cursor = {
        cursor = mkDefault "maomao"; #maomao
      };

      fonts = {
        cartograph-cf.enable = mkDefault true; # general monospace
        ibm-plex.enable = mkDefault true; # obsidian
      };

      terminal = {
        emulator = mkDefault "kitty";
        backgroundOpacity = mkDefault config.theme.win.opacity.background;
      };

      rofi = {
        enable = mkDefault true;
        themeFile = let
          womenInChair = pkgs.fetchurl {
            url = "https://github.com/adi1090x/rofi/raw/093c1a79f58daab358199c4246de50357e5bf462/files/images/e.jpg";
            hash = "sha256-KyA/KpARKAF8XQWmGnOnJLkXM1/pT39DGjguZz4AZcw=";
          };
          wallhaven-xe59v3 = ./rofi/wallhaven-xe59v3-cropped.png;
          rasi =
            import ./rofi/theme.nix
            wallhaven-xe59v3
            config.theme.launcher
            "${config.theme.fonts.monospace} Italic 11";
        in
          mkDefault (pkgs.writeText "theme.rasi" rasi);
      };

      todoist.quickAdd.rofi.configFile = let
        rasi = import ./rofi/todoist-quick-add.nix {};
      in
        mkDefault (pkgs.writeText "config.rasi" rasi);

      ytm = {
        stylesheetFile = mkDefault ./ytm/stylesheet.css;
      };

      zathura = {
        zathurarc =
          # zathurarc
          ''
            set recolor "true"
            set default-bg rgba(45,53,59,0.7)
            set recolor-lightcolor rgba(0,0,0,0)
            set adjust-open "width"
          '';
      };

      nixvim = {
        transparency.enable = mkDefault true;
        colors.theme = "everforest";
      };

      starship = {
        presets = [
          "nerd-font-symbols"
        ];
        settings = {
          cmd_duration = {
            disabled = true;
          };
        };
      };

      discord.vesktop = {
        theme = "system24-everforest";
      };

      wallust = {
        enable = true;
        wallpaper = pkgs.fetchurl {
          url = "https://w.wallhaven.cc/full/p9/wallhaven-p9vyz3.jpg";
          hash = "sha256-bo2omvgTQ8oOoAbuxXTiRLSVAevUA4Tu60IUHCM99bA=";
        };
        settings = {
          backend = "fastresize";
          color_space = "lch";
          palette = "dark";
        };
      };
    };
    programs = {
      waybar = {
        style = let
          bars = {
            barRight = "right";
            barLeft = "left";
            barCenter = "center";
          };

          selectBarsIfEnabled = let
            cfg = config.programs.waybar.settings;
          in
            modules: (strings.concatStrings
              (attrsets.mapAttrsToList (bar: monitor: (
                  if
                    ((builtins.hasAttr bar cfg)
                      && (builtins.hasAttr modules cfg.${bar})
                      && (builtins.isList cfg.${bar}.${modules})
                      && (cfg.${bar}.${modules} != []))
                  then
                    #css
                    "window.${monitors.devices.${monitor}.name} .${modules}, "
                  else ""
                ))
                bars)
              + "unreachable");
        in "${pkgs.writeText "waybar.css"
          #css
          ''
            @import url("colors.css");

            * {
                font-size:15px;
                font-family: "${config.theme.fonts.monospace}";
            }
            window#waybar{
                all:unset;
            }

            ${selectBarsIfEnabled "modules-left"} {
                padding:7px;
                margin:10 0 5 10;
                border-radius:10px;
                background: alpha(@background, ${toString config.theme.win.opacity.background});
                box-shadow: 0px 0px 2px rgba(0, 0, 0, .6);
            }
            ${selectBarsIfEnabled "modules-center"} {
                padding:7px;
                margin:10 0 5 0;
                border-radius:10px;
                background: alpha(@background, ${toString config.theme.win.opacity.background});
                box-shadow: 0px 0px 2px rgba(0, 0, 0, .6);
            }
            ${selectBarsIfEnabled "modules-right"}
             {
                padding:7px;
                margin: 10 10 5 0;
                border-radius:10px;
                background: alpha(@background, ${toString config.theme.win.opacity.background});
                box-shadow: 0px 0px 2px rgba(0, 0, 0, .6);
            }

            tooltip {
                background:@background;
                color: @color7;
            }
            #clock:hover, #custom-pacman:hover, #custom-nixpkgs:hover, #custom-notification:hover,#bluetooth:hover,#network:hover,#battery:hover, #cpu:hover,#memory:hover,#temperature:hover{
                transition: all .3s ease;
                color:@color9;
            }
            #custom-notification {
                padding: 0px 5px;
                transition: all .3s ease;
                color:@color7;
            }
            #clock{
                padding: 0px 5px;
                color:@color7;
                transition: all .3s ease;
            }
            #custom-pacman {
                padding: 0px 5px;
                transition: all .3s ease;
                color:@color7;
            }
            #custom-nixpkgs {
                padding: 0px 5px;
                transition: all .3s ease;
                color:@color7;
            }
            #workspaces {
                padding: 0px 5px;
            }
            #workspaces button {
                all:unset;
                padding: 0px 5px;
                color: alpha(@color9,.4);
                transition: all .2s ease;
            }
            #workspaces button:hover {
                color:rgba(0,0,0,0);
                border: none;
                text-shadow: 0px 0px 1.5px rgba(0, 0, 0, .5);
                transition: all 1s ease;
            }
            #workspaces button.active {
                color: @color9;
                border: none;
                text-shadow: 0px 0px 2px rgba(0, 0, 0, .5);
            }
            #workspaces button.empty {
                color: rgba(0,0,0,0);
                border: none;
                text-shadow: 0px 0px 1.5px rgba(0, 0, 0, .2);
            }
            #workspaces button.empty:hover {
                color: rgba(0,0,0,0);
                border: none;
                text-shadow: 0px 0px 1.5px rgba(0, 0, 0, .5);
                transition: all 1s ease;
            }
            #workspaces button.empty.active {
                color: @color9;
                border: none;
                text-shadow: 0px 0px 2px rgba(0, 0, 0, .5);
            }
            #bluetooth{
                padding: 0px 5px;
                transition: all .3s ease;
                color:@color7;

            }
            #network{
                padding: 0px 5px;
                margin-right: 5px;
                transition: all .3s ease;
                color:@color7;

            }
            #battery{
                padding: 0px 5px;
                transition: all .3s ease;
                color:@color7;


            }
            #battery.charging {
                color: #26A65B;
            }

            #battery.warning:not(.charging) {
                color: #ffbe61;
            }

            #battery.critical:not(.charging) {
                color: #f53c3c;
                animation-name: blink;
                animation-duration: 0.5s;
                animation-timing-function: linear;
                animation-iteration-count: infinite;
                animation-direction: alternate;
            }
            #group-expand{
                padding: 0px 5px;
                transition: all .3s ease;
            }
            #custom-expand{
                padding: 0px 5px;
                color:alpha(@foreground,.5);
                text-shadow: 0px 0px 2px rgba(0, 0, 0, .7);
                transition: all .3s ease;
            }
            #custom-expand:hover{
                color:rgba(255,255,255,.2);
                text-shadow: 0px 0px 2px rgba(255, 255, 255, .5);
            }
            #cpu,#memory,#temperature{
                padding: 0px 5px;
                transition: all .3s ease;
                color:@color7;

            }
            #custom-endpoint{
                color:alpha(@foreground,.5);
                text-shadow: 0px 0px 1.5px rgba(0, 0, 0, 1);

            }
            #tray{
                padding: 0px 5px;
                transition: all .3s ease;

            }
            #tray menu * {
                padding: 0px 5px;
                transition: all .3s ease;
            }

            #tray menu separator {
                padding: 0px 5px;
                transition: all .3s ease;
            }
          ''}";

        settings = let
          default = {
            left = ["custom/notification" "clock" "custom/nixpkgs" "tray"];
            center = ["hyprland/workspaces"];
            right = ["group/expand" "bluetooth" "network" "battery"];
            bar = monitor: (
              {
                layer = "top";
                position = "top";
                height = 30;
                output = [monitors.devices.${monitor}.name];
                reload_style_on_change = true;
              }
              // (modules monitor)
            );
          };
          mapping = {
            "-" = {
              barCenter =
                (default.bar "center")
                // {
                  modules-left = default.left;
                  modules-center = default.center;
                  modules-right = default.right;
                };
            };
            "|-|" = {
              barRight =
                (default.bar "right")
                // {
                  modules-center = default.right;
                };
              barLeft =
                (default.bar "left")
                // {
                  modules-center = default.left;
                };
            };
          };

          modules = monitor: {
            "hyprland/workspaces" = {
              "format" = "{icon}";
              "format-icons" = {
                "active" = "";
                "default" = "";
                "empty" = "";
              };
              "persistent-workspaces" = {
                "*" = monitors.devices.${monitor}.workspaces;
              };
            };
            "custom/notification" = {
              "tooltip" = false;
              "format" = " ";
              "on-click" = "#TODO: notification client";
              "escape" = true;
            };
            "clock" = {
              "format" = "{:%I:%M:%S %p} ";
              "interval" = 1;
              "tooltip-format" = "<tt>{calendar}</tt>";
              "calendar" = {
                "format" = {
                  "today" = "<span color='#fAfBfC'><b>{}</b></span>";
                };
              };
              "actions" = {
                "on-click-right" = "shift_down";
                "on-click" = "shift_up";
              };
            };
            "network" = {
              "format-wifi" = "";
              "format-ethernet" = "";
              "format-disconnected" = "";
              "tooltip-format-disconnected" = "Error";
              "tooltip-format-wifi" = "{essid} ({signalStrength}%) ";
              "tooltip-format-ethernet" = "{ifname} 🖧 ";
              "on-click" = "kitty nmtui";
            };
            "bluetooth" = {
              "format-on" = "󰂯";
              "format-off" = "BT-off";
              "format-disabled" = "󰂲";
              "format-connected-battery" = "{device_battery_percentage}% 󰂯";
              "format-alt" = "{device_alias} 󰂯";
              "tooltip-format" = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
              "tooltip-format-connected" = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
              "tooltip-format-enumerate-connected" = "{device_alias}\n{device_address}";
              "tooltip-format-enumerate-connected-battery" = "{device_alias}\n{device_address}\n{device_battery_percentage}%";
              "on-click-right" = config.modules.bluetooth.app;
            };
            "battery" = {
              "interval" = 30;
              "states" = {
                "good" = 95;
                "warning" = 30;
                "critical" = 20;
              };
              "format" = "{capacity}% {icon}";
              "format-charging" = "{capacity}% 󰂄";
              "format-plugged" = "{capacity}% 󰂄 ";
              "format-alt" = "{time} {icon}";
              "format-icons" = [
                "󰁻"
                "󰁼"
                "󰁾"
                "󰂀"
                "󰂂"
                "󰁹"
              ];
            };
            "custom/pacman" = {
              "format" = "󰅢 {}";
              "interval" = 30;
              "exec" = "checkupdates | wc -l";
              "exec-if" = "exit 0";
              "on-click" = "${config.vars.terminal} sh -c 'yay -Syu; echo Done - Press enter to exit; read'; pkill -SIGRTMIN+8 waybar";
              "signal" = 8;
              "tooltip" = false;
            };
            "custom/nixpkgs" = let
              flakeInputsToUpdate = lists.subtractLists ["private" "self"] (builtins.attrNames inputs);
              inputsStr = lib.concatStringsSep " " flakeInputsToUpdate;
              flake = inputs.self;
            in {
              format = "󰅢 {}";
              interval = 300;
              exec = let
                updateScript = pkgs.writeShellScript "check-nix-updates" ''
                  if [[ -d ${flake} ]]; then
                    cd ${flake}
                    UPDATES=$(nix flake update --output-lock-file <(cat flake.nix) ${inputsStr} 2>&1 | grep -E "(→|↓)" | wc -l)
                    echo "$UPDATES"
                  else
                    echo "0"
                  fi
                '';
              in "${updateScript}";
              exec-if = "test -d ${flake}";
              on-click = "${config.vars.terminal} sh -c 'cd ${flake} && nix flake update ${inputsStr} && echo \"Flake updated! && echo \"Press enter to exit\"; read'";
              on-click-right = "${config.vars.terminal} sh -c 'cd ${flake} && sudo nixos-rebuild switch --flake .; echo \"Press enter to exit\"; read'"; #TODO: do we need to provide the host?
              signal = 8;
              tooltip = true;
              tooltip-format = "{} Nix updates available\nLeft-click: Update flake\nRight-click: Rebuild system";
            };
            "custom/expand" = {
              "format" = "";
              "tooltip" = false;
            };
            "custom/endpoint" = {
              "format" = "|";
              "tooltip" = false;
            };
            "group/expand" = {
              "orientation" = "horizontal";
              "drawer" = {
                "transition-duration" = 600;
                "transition-to-left" = true;
                "click-to-reveal" = true;
              };
              "modules" = ["custom/expand" "cpu" "memory" "temperature" "custom/endpoint"];
            };
            "cpu" = {
              "format" = "󰻠";
              "tooltip" = true;
            };
            "memory" = {
              "format" = "";
            };
            "temperature" = {
              "critical-threshold" = 80;
              "format" = "";
            };
            "tray" = {
              "icon-size" = 14;
              "spacing" = 10;
            };
          };
        in
          mapping.${monitors.arrangement.byPictogram};
      };
    };
    theme = {
      fonts = {
        monospace = "CartographCF Nerd Font";
        reading = "IBM Plex";
      };
      launcher = {
        # https://github.com/rebelot/kanagawa.nvim/blob/aef7f5cec0a40dbe7f3304214850c472e2264b10/lua/kanagawa/colors.lua
        background = mkDefault "#272E33";
        border = mkDefault "#7A8478";
        background-alt = mkDefault "#2E383C";
        foreground = mkDefault "#D3C6AA";
        foreground-selected = mkDefault "#272E33";
        selected = mkDefault "#7FBBB3";
        active = mkDefault "#A7C080";
        urgent = mkDefault "#E67E80";
      };
      win = {
        border = {
          active = "#9da9a000";
          inactive = "#85928900";
          size = 0;
        };
        shadow = {
          active = "#8d78909f";
          inactive = "#33333390";
          range = 5;
          render_power = 3;
        };
        opacity = {
          active = 1.0;
          inactive = 1.0;
          background = 0.7;
        };
        corners = {
          rounding = 12;
          rounding_power = 2;
        };
        blur = {
          size = 20;
          passes = 4;
          vibrancy = 1.0;
        };
        layout = {
          gaps_in = 10;
          gaps_out = 15;
        };
      };
      term = {
        padding = 4;

        foreground = "                     #d3c6aa";
        background = "                     #2d353b";
        selection_foreground = "           #9da9a0";
        selection_background = "           #505a60";

        cursor = "                         #d3c6aa";
        # cursor_text_color = "              #343f44";

        # url_color = "                      #7fbbb3";

        # active_border_color = "            #a7c080";
        # inactive_border_color = "          #56635f";
        # bell_border_color = "              #e69875";
        # visual_bell_color = "              none";

        # wayland_titlebar_color = "         system";
        # macos_titlebar_color = "           system";

        # active_tab_background = "          #2d353b";
        # active_tab_foreground = "          #d3c6aa";
        # inactive_tab_background = "        #3d484d";
        # inactive_tab_foreground = "        #9da9a0";
        # tab_bar_background = "             #343f44";
        # tab_bar_margin_color = "           none";

        # mark1_foreground = "               #2d353b";
        # mark1_background = "               #7fbbb3";
        # mark2_foreground = "               #2d353b";
        # mark2_background = "               #d3c6aa";
        # mark3_foreground = "               #2d353b";
        # mark3_background = "               #d699b6";

        #: = "black";
        color0 = "                         #343f44";
        color8 = "                         #868d80";

        #: = "red";
        color1 = "                         #e67e80";
        color9 = "                         #e67e80";

        #: = "green";
        color2 = "                         #a7c080";
        color10 = "                        #a7c080";

        #: = "yellow";
        color3 = "                         #dbbc7f";
        color11 = "                        #dbbc7f";

        #: = "blue";
        color4 = "                         #7fbbb3";
        color12 = "                        #7fbbb3";

        #: = "magenta";
        color5 = "                         #d699b6";
        color13 = "                        #d699b6";

        #: = "cyan";
        color6 = "                         #83c092";
        color14 = "                        #83c092";

        #: = "white";
        color7 = "                         #859289";
        color15 = "                        #9da9a0";
      };
      wallpapers = rec {
        arrangements = with images; {
          "|-|" = {
            left = horz2;
            center = horz1;
            right = horz2;
          };
          "-" = {
            center = horz1;
          };
        };
        images = {
          vert1 = pkgs.fetchurl {
            url = "https://w.wallhaven.cc/full/ex/wallhaven-exj8jl.jpg";
            hash = "sha256-sC6gYIAgTlFNFdn9dbvPj3ZQ6u6KGX5ImyHRU/BZ2bw=";
          };
          vert2 = pkgs.fetchurl {
            url = "https://w.wallhaven.cc/full/o3/wallhaven-o3k6ol.jpg";
            hash = "sha256-g5XH8n+rZnr1fw2YifqzxWJto8UeBo3VBOPYyrGxgtg=";
          };
          horz1 = pkgs.fetchurl {
            url = "https://w.wallhaven.cc/full/qr/wallhaven-qr2dxr.jpg";
            hash = "sha256-Sca+LBBAVS7xFjhO24dwsAHs9vqoqMZb6Ce4yF15BqM=";
          };
          horz2 = pkgs.fetchurl {
            url = "https://w.wallhaven.cc/full/6l/wallhaven-6lo8w6.png";
            hash = "sha256-tGHSZEPIRagf1IG4henexc+HJ1vnZWWdE5Fc3n6LUt0=";
          };
        };
      };
    };
  };
}
#
#TODO: add a hardcoded workspace config with this:
#
# Window 564604f32650 -> clearfetch:
#         mapped: 1
#         hidden: 0
#         at: 42,585
#         size: 976,468
#         workspace: 1 (1)
#         floating: 1
#         pseudo: 0
#         monitor: 0
#         class: kitty
#         title: clearfetch
#         initialClass: kitty
#         initialTitle: kitty
#         pid: 106965
#         xwayland: 0
#         pinned: 0
#         fullscreen: 0
#         fullscreenClient: 0
#         grouped: 0
#         tags:
#         swallowing: 0
#         focusHistoryID: 1
#         inhibitingIdle: 0
#         xdgTag:
#         xdgDescription:
# Window 564604f37720 -> lf:
#         mapped: 1
#         hidden: 0
#         at: 1488,580
#         size: 409,1020
#         workspace: 1 (1)
#         floating: 1
#         pseudo: 0
#         monitor: 0
#         class: kitty
#         title: lf
#         initialClass: kitty
#         initialTitle: kitty
#         pid: 107926
#         xwayland: 0
#         pinned: 0
#         fullscreen: 0
#         fullscreenClient: 0
#         grouped: 0
#         tags:
#         swallowing: 0
#         focusHistoryID: 2
#         inhibitingIdle: 0
#         xdgTag:
#         xdgDescription:
# Window 5646055c5dc0 -> tmux:
#         mapped: 1
#         hidden: 0
#         at: 39,1101
#         size: 1386,507
#         workspace: 1 (1)
#         floating: 1
#         pseudo: 0
#         monitor: 0
#         class: kitty
#         title: tmux
#         initialClass: kitty
#         initialTitle: kitty
#         pid: 108556
#         xwayland: 0
#         pinned: 0
#         fullscreen: 0
#         fullscreenClient: 0
#         grouped: 0
#         tags:
#         swallowing: 0
#         focusHistoryID: 0
#         inhibitingIdle: 0
#         xdgTag:
#         xdgDescription:

