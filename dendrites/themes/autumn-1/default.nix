{
  inputs,
  self,
  ...
}: let
  name = "autumn-1";
in
  with inputs.nixpkgs.lib; {
    flake.nixosModules."themes/${name}" = {config, ...}: let
      cfg = config.themes.${name};
    in {
      imports = [
        self.nixosModules.hyprland
        self.nixosModules.hyprlock
      ];

      options.themes.${name} = {
        enable = mkEnableOption "[Theme] ${name}";
      };

      config = mkIf cfg.enable {
        modules = {
          steam.enable = true; # wallpaperengine
          hyprland.enable = true;
          hyprlock.enable = true;
        };
      };
    };

    flake.homeModules."themes/${name}" = {
      config,
      pkgs,
      ...
    }: let
      cfg = config.themes.${name};

      inherit (config) utils;
      inherit (config.vars) monitors;
      inherit (config.theme) wallpapers;
    in {
      imports = [
        self.homeModules.hyprland
        self.homeModules.waybar
        self.homeModules.hyprshot
        self.homeModules.hyprpicker
        self.homeModules.hyprlock
        self.homeModules.linux-wallpaperengine
      ];

      options.themes.${name} = {
        enable = mkEnableOption "[Theme] ${name}";
      };

      config = mkIf cfg.enable {
        vars = {
          editor = mkDefault "nvim";
          sysfetcher = mkDefault "fastfetch";
          terminal = mkDefault "kitty";
        };

        services.linux-wallpaperengine = {
          wallpapers = [
            {
              screenSpan = with monitors.devices; [
                left.name
                center.name
                right.name
              ];
              wallpaperId = "1512181248";
              scaling = "fill";
              audio.silent = true;
            }
          ];
        };

        modules = {
          waybar.enable = mkDefault true;
          hyprshot.enable = mkDefault true;
          hyprpicker.enable = mkDefault true;
          hyprlock.enable = mkDefault true;
          hyprland.enable = mkDefault true;

          cursor = {
            cursor = mkDefault "frieren-winter";
          };

          fonts = {
            cartograph-cf.enable = mkDefault true; # general monospace
            jetbrains-mono.enable = mkDefault true;
            ibm-plex.enable = mkDefault true; # obsidian
          };

          terminal = {
            emulator = mkDefault "kitty";
            backgroundOpacity = mkDefault config.theme.win.opacity.background;
          };

          rofi = {
            enable = mkDefault true;
            themeFile = let
              walName = "wallhaven-e83378.jpg";
              rawImg = "${pkgs.fetchurl {
                url = "https://w.wallhaven.cc/full/e8/${walName}";
                hash = "sha256-ms2DG7koNAjbnR6nDVFrDfhokErcHeMv7lvuSMvDsTU=";
              }}";
              # todo: figure out exact size we need
              # scaling down the bg image, otherwise it takes like 500ms to load
              img = utils.resizeImage 1000 1000 rawImg walName;
              rasi =
                import ./rofi/theme.nix
                "${img}/share/${walName}"
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
                set default-bg rgba(41,37,34,${toString config.theme.win.opacity.background})
                set recolor-lightcolor rgba(0,0,0,0)
                set adjust-open "width"
              '';
          };

          nixvim = {
            transparency.enable = mkDefault true;
            colors.theme = "gruvbox-material";
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
            theme = "midnight-vencord";
          };

          wallust = {
            enable = true;
            wallpaper = ./pywal/wpe-1512181248.png;
            settings = {
              backend = "fastresize";
              color_space = "lch";
              palette = "dark";
              templates = {
                waybar = {
                  template = "waybar.css";
                  target = "~/.config/waybar/colors.css";
                };
              };
            };
          };

          wallpaperengine.enable = true;

          hyprland.modules = {
            # todo: https://knowledgebase.frame.work/en_us/tablet-mode-and-screen-rotation-on-linux-SJkaIhBSbg
            # is this any better / even relevant?
            "rotate-screen".conf = let
              n = "center";
              v = monitors.devices.${n};
              formatted =
                config.utils.fmtMonitor_device
                n
                v
                (monitors.arrangement.byName.${v.name} // {r = 2;});
            in
              #hyprlang
              ''
                monitor = ${formatted}
                input {
                  touchdevice {
                    transform = 2
                  }
                  tablet {
                    transform = 2
                  }
                  touchpad {
                    flip_x = true
                    flip_y = true
                  }
                }
              '';
          };
        };

        programs.hyprlock = let
          fmtColor = config.utils.fmtColor_rgbaFn;
          fmtColorWO = config.utils.fmtColorWithOpacity_rgbaFn;
          inherit (config.utils) ftop ftoi;
          escape = replaceStrings ["#" ''"''] ["##" ''\"''];
        in {
          # inspiration: https://www.hyprflux.dev/features/hyprlock.html#features
          settings = {
            animations = {
              enabled = true;
              fade_in = {
                duration = 300;
              };
              fade_out = {
                duration = 100;
              };
            };

            general = {
              immediate_render = true;
            };

            background = let
              devs = monitors.devices;
              pict = monitors.arrangement.byPictogram;
              wals = wallpapers.arrangements.${pict};
            in
              attrsets.mapAttrsToList (
                k: v:
                  if (hasAttr k wals)
                  then {
                    monitor = v.name;
                    path = toString wals.${k};
                    crossfade_time = 1.0;
                  }
                  else throw "wallpaper for ${k} monitor '${v.name}' is missing."
              )
              devs;

            input-field = [
              {
                monitor = monitors.devices.center.name;
                size = "300, 50";

                dots_size = 0.2;
                dots_spacing = 0.2;
                dots_center = true;

                outline_thickness = 0;
                shadow_color = fmtColor config.theme.win.shadow.active;
                shadow_size = 1;
                shadow_passes = 3;

                rounding = 0;

                inner_color = fmtColorWO config.theme.term.background "BB";
                font_color = fmtColor config.theme.launcher.foreground;
                fade_on_empty = false;
                font_family = "${config.theme.fonts.monospace}";
                placeholder_text = ''<i><span foreground="#${config.theme.launcher.foreground}">🔒 Enter Pass</span></i>'';
                hide_input = false;
                halign = "center";
                valign = "center";
              }
            ];

            # Date display
            label = [
              {
                monitor = monitors.devices.center.name;
                text = ''cmd[update:1000] echo -e "$(LC_TIME=en_US.UTF-8 date +"%A, %B %d")"'';
                color = fmtColor config.theme.launcher.foreground;
                font_size = 25;
                font_family = "${config.theme.fonts.monospace}";
                position = "0, 350";
                halign = "center";
                valign = "center";
              }

              # Time display
              {
                monitor = monitors.devices.center.name;
                text = ''cmd[update:1000] echo "<span>$(date +"%I:%M")</span>"'';
                color = fmtColor config.theme.launcher.foreground;
                font_size = 120;
                font_family = "${config.theme.fonts.monospace}";
                position = "0, 230";
                halign = "center";
                valign = "center";
              }

              # Song information
              {
                monitor = monitors.devices.center.name;
                text = let
                  script = "${pkgs.writeShellScript "songdetails" ''
                    # Get current playing song from playerctl
                    if command -v playerctl &> /dev/null; then
                        # Check if any player is running
                        if playerctl status &> /dev/null; then
                            artist=$(playerctl metadata artist 2>/dev/null)
                            title=$(playerctl metadata title 2>/dev/null)

                            if [[ -n "$artist" && -n "$title" ]]; then
                                echo "♪ $artist - $title"
                            elif [[ -n "$title" ]]; then
                                echo "♪ $title"
                            else
                                echo "♪ Music Playing"
                            fi
                        else
                            echo ""
                        fi
                    else
                        echo ""
                    fi
                  ''}";
                  bg = "${config.theme.term.background}";
                  al = "${toString (ftoi (ftop config.theme.win.opacity.background))}%";
                  text =
                    # html
                    ''<span bgcolor='${bg}' bgalpha='${al}'> <i>$(${script})</i> </span>'';
                in ''cmd[update:1000] echo "${escape text}"'';
                color = fmtColor config.theme.launcher.foreground;
                shadow_color = fmtColor config.theme.win.shadow.active;
                shadow_size = 1;
                shadow_passes = 3;
                font_size = 20;
                font_family = "${config.theme.fonts.monospace}";
                position = "0, 50";
                halign = "center";
                valign = "bottom";
              }
            ];
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

              bgColor = "rgba(41,37,34,${toString config.theme.win.opacity.background})";

              gaps_in = toString config.theme.win.layout.gaps_in;
              gaps_out = toString config.theme.win.layout.gaps_out;
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
                    margin: ${gaps_out} ${gaps_in} 0 ${gaps_out};
                    border-radius:10px;
                    background: alpha(@background, ${toString config.theme.win.opacity.background});
                    box-shadow: 0px 0px 2px ${bgColor};
                }
                ${selectBarsIfEnabled "modules-center"} {
                    padding:7px;
                    margin:10 0 5 0;
                    margin: ${gaps_out} ${gaps_in} 0 ${gaps_in};
                    border-radius:10px;
                    background: alpha(@background, ${toString config.theme.win.opacity.background});
                    box-shadow: 0px 0px 2px ${bgColor};
                }
                ${selectBarsIfEnabled "modules-right"}
                 {
                    padding:7px;
                    margin: ${gaps_out} ${gaps_out} 0 ${gaps_in};
                    border-radius:10px;
                    background: alpha(@background, ${toString config.theme.win.opacity.background});
                    box-shadow: 0px 0px 2px ${bgColor};
                }

                tooltip {
                    background:@background;
                    color: @foreground;
                }
                #clock:hover, #custom-pacman:hover, #custom-nixpkgs:hover, #custom-rotate-screen:hover, #custom-notification:hover,#bluetooth:hover,#network:hover,#battery:hover, #cpu:hover,#memory:hover,#temperature:hover{
                    transition: all .3s ease;
                    color:@color9;
                }
                #custom-notification {
                    padding: 0px 5px;
                    transition: all .3s ease;
                    color:@foreground;
                }
                #clock{
                    padding: 0px 5px;
                    color:@foreground;
                    transition: all .3s ease;
                }
                #custom-pacman {
                    padding: 0px 5px;
                    transition: all .3s ease;
                    color:@foreground;
                }
                #custom-nixpkgs {
                    padding: 0px 5px;
                    transition: all .3s ease;
                    color:@foreground;
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
                #custom-rotate-screen {
                    padding: 0px 5px;
                    transition: all .3s ease;
                    color:@foreground;
                }
                #bluetooth{
                    padding: 0px 5px;
                    transition: all .3s ease;
                    color:@foreground;
                }
                #pulseaudio{
                    padding: 0px 5px;
                    transition: all .3s ease;
                    color:@foreground;
                }
                #network{
                    padding: 0px 5px;
                    margin-right: 5px;
                    transition: all .3s ease;
                    color:@foreground;
                }
                #battery{
                    padding: 0px 5px;
                    transition: all .3s ease;
                    color:@foreground;
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
                    color:@foreground;

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
                center = ["hyprland/workspaces" "custom/rotate-screen"];
                right = ["group/expand" "pulseaudio" "bluetooth" "network" "battery"];
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
                "pulseaudio" = {
                  "max-volume" = 100;
                  "scroll-step" = 10;
                  "format" = "{icon}";
                  "tooltip-format" = "{volume}%";
                  "format-muted" = "×";
                  "format-icons" = [
                    " "
                    " "
                    " "
                  ];
                  "on-click" = "${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
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
                  inputsStr = concatStringsSep " " flakeInputsToUpdate;
                  flake = config.vars.flake.dir;
                in {
                  format = "󰅢 {}";
                  interval = 300;
                  exec = let
                    updateScript = pkgs.writeShellScript "check-nix-updates" ''
                      if [[ -d ${flake} ]]; then
                        cd ${flake} || return

                        if [[ -z "$(git status --porcelain)" ]]; then

                          # not using --reference-lock-file "$in" --output-lock-file "$out" bc then nix doesn't tell us about what was updated :shrug:
                          updates=$(nix flake update \
                            ${inputsStr} 2>&1 \
                            | grep -c "Updated input"
                          )

                          git reset --hard 2>&1

                          echo " $updates"
                          exit 0
                        fi
                      fi

                      echo " ?"
                    '';
                  in "${updateScript}";
                  exec-if = "test -d ${flake}";
                  on-click = "${config.vars.terminal} sh -c 'cd ${flake} && nix flake update ${inputsStr} && echo \"Flake updated! && echo \"Press enter to exit\"; read'";
                  on-click-right = "${config.vars.terminal} sh -c 'cd ${flake} && sudo nixos-rebuild switch --flake .; echo \"Press enter to exit\"; read'"; #TODO: do we need to provide the host?
                  signal = 8;
                  tooltip = true;
                  tooltip-format = "{} Nix updates available\nLeft-click: Update flake\nRight-click: Rebuild system";
                };
                "custom/rotate-screen" = {
                  format = "⟳";
                  on-click = config.modules.hyprland.modules."rotate-screen".scripts.toggle;
                  tooltip = true;
                  tooltip-format = "Flip screen upside down.";
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
            monospace = "Jetbrains Mono Nerd Font";
            reading = "IBM Plex";
          };
          launcher = {
            background = mkDefault config.theme.term.selection_background;
            border = mkDefault config.theme.win.border.active;
            background-alt = mkDefault config.theme.term.color4;
            foreground = mkDefault config.theme.term.selection_foreground;
            foreground-selected = mkDefault config.theme.term.foreground;
            selected = mkDefault config.theme.term.background;
            active = mkDefault config.theme.term.color2;
            urgent = mkDefault config.theme.term.color1;
          };
          win = {
            border = {
              active = "${config.theme.term.color12}ff";
              inactive = "${config.theme.term.color4}ff";
              size = 1;
            };
            shadow = {
              active = "#11111100";
              inactive = "#00000000";
              range = 7;
              render_power = 3;
            };
            opacity = {
              active = 1.0;
              inactive = 1.0;
              background = 0.75;
            };
            corners = {
              rounding = 10;
              rounding_power = 2;
            };
            blur = {
              size = 6;
              passes = 3;
              vibrancy = 1.0;
            };
            layout = {
              gaps_in = 10;
              gaps_out = 15;
            };
          };
          term = let
            conf = builtins.readFile ./kitty/${"Gruvbox Material Dark Soft.conf"};
            theme = utils.importKittyTheme conf;
          in
            theme // {padding = 2;};

          wallpapers = rec {
            arrangements = {
              "|-|" = {
                inherit (images) left center right;
              };
              "-" = {
                center = images.normal;
              };
            };
            images = {
              left = "${./wpe-1512181248_left.png}";
              right = "${./wpe-1512181248_right.png}";
              center = "${./wpe-1512181248_center.png}";
              normal = "${./wpe-1512181248.png}";
            };
          };
        };
      };
    };
  }
