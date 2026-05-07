{
  inputs,
  self,
  ...
}: let
  name = "idekanymore";
in
  with inputs.nixpkgs.lib; {
    flake.nixosModules."themes/${name}" = {config, ...}: let
      cfg = config.themes.${name};
    in {
      imports = [
        self.nixosModules.hyprland
      ];

      options.themes.${name} = {
        enable = mkEnableOption "[Theme] ${name}";
      };

      config = mkIf cfg.enable {
        # wallpaperengine
        modules.steam.enable = true;
        modules.hyprland.enable = true;
        modules.hyprlock.enable = true;
      };
    };

    flake.homeModules."themes/${name}" = args @ {
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
        self.homeModules.dunst
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
              monitor = monitors.devices.center.name;
              wallpaperId = "3620156165";
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
            cursor = mkDefault "maomao";
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
              walName = "wallhaven-y8622k.jpg";
              rawImg = "${pkgs.fetchurl {
                url = "https://w.wallhaven.cc/full/y8/${walName}";
                hash = "sha256-jM8uWatQehi5YntaYfQGQ9VFoqOpMr8ZkoInvunQmu8=";
              }}";
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
            wallpaper = ./wpe-3620156165.png;
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
                # position = "0, -210";
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
                  // (let
                    importModule = name: import ../../waybar/modules/${name}.nix ({inherit monitor;} // args);
                  in {
                    "hyprland/workspaces" = importModule "hyprland/workspaces";
                    "custom/notification" = importModule "custom/notification";
                    "clock" = importModule "clock";
                    "network" = importModule "network";
                    "bluetooth" = importModule "bluetooth";
                    "pulseaudio" = importModule "pulseaudio";
                    "battery" = importModule "battery";
                    "custom/pacman" = importModule "custom/pacman";
                    "custom/nixpkgs" = importModule "custom/nixpkgs";
                    "custom/rotate-screen" = importModule "custom/rotate-screen";
                    "custom/expand" = importModule "custom/expand";
                    "custom/endpoint" = importModule "custom/endpoint";
                    "group/expand" = importModule "group/expand";
                    "cpu" = importModule "cpu";
                    "memory" = importModule "memory";
                    "temperature" = importModule "temperature";
                    "tray" = importModule "tray";
                  })
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
            # https://github.com/rebelot/kanagawa.nvim/blob/aef7f5cec0a40dbe7f3304214850c472e2264b10/lua/kanagawa/colors.lua
            background = mkDefault "#272E33";
            border = mkDefault "#7A8478";
            background-alt = mkDefault "#2E383C";
            foreground = mkDefault "#ECE1D7";
            foreground-selected = mkDefault config.theme.term.selection_foreground; # todo ?
            selected = mkDefault "#7F91B2";
            active = mkDefault "#78997A";
            urgent = mkDefault "#BD8183";
          };
          win = {
            border = {
              active = "${config.theme.term.color2}ff";
              inactive = "${config.theme.term.color6}ff";
              size = 2;
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
              background = 0.9;
            };
            corners = {
              rounding = 12;
              rounding_power = 2;
            };
            blur = {
              size = 6;
              passes = 3;
              vibrancy = 2.0;
            };
            layout = {
              gaps_in = 10;
              gaps_out = 15;
            };
          };
          term = let
            conf = builtins.readFile ./kitty/${"Gruvbox Material Dark Medium.conf"};
            theme = utils.importKittyTheme conf;
          in
            theme // {padding = 4;};

          wallpapers = rec {
            arrangements = with images; {
              "|-|" = {
                left = vert1;
                center = horz1;
                right = vert2;
              };
              "-" = {
                center = horz1;
              };
            };
            # todo: screenshot the live wallpaper using linux-wallpaperengine and use that as fallback
            images = {
              vert1 = "${pkgs.fetchurl {
                url = "https://w.wallhaven.cc/full/ex/wallhaven-exj8jl.jpg";
                hash = "sha256-sC6gYIAgTlFNFdn9dbvPj3ZQ6u6KGX5ImyHRU/BZ2bw=";
              }}";
              vert2 = "${pkgs.fetchurl {
                url = "https://w.wallhaven.cc/full/o3/wallhaven-o3k6ol.jpg";
                hash = "sha256-g5XH8n+rZnr1fw2YifqzxWJto8UeBo3VBOPYyrGxgtg=";
              }}";
              horz1 = "${pkgs.fetchurl {
                url = "https://w.wallhaven.cc/full/p9/wallhaven-p9vyz3.jpg";
                hash = "sha256-bo2omvgTQ8oOoAbuxXTiRLSVAevUA4Tu60IUHCM99bA=";
              }}";
            };
          };
        };
      };
    };
  }
