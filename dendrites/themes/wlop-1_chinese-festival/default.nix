{
  inputs,
  self,
  ...
}: let
  name = "wlop-1_chinese-festival";
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
          hyprland.enable = true;
          hyprlock.enable = true;
        };
      };
    };

    flake.homeModules."themes/${name}" = args @ {
      config,
      pkgs,
      ...
    }: let
      cfg = config.themes.${name};

      inherit (config.vars) monitors;
    in {
      imports = [
        self.homeModules.hyprland
        self.homeModules.waybar
        self.homeModules.hyprshot
        self.homeModules.hyprpicker
        self.homeModules.hyprlock
        self.homeModules.hyprpaper
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

        modules = {
          waybar.enable = mkDefault true;
          hyprshot.enable = mkDefault true;
          hyprpicker.enable = mkDefault true;
          hyprlock.enable = mkDefault true;
          hyprland.enable = mkDefault true;
          hyprpaper.enable = mkDefault true;

          cursor = {
            cursor = mkDefault "frieren-winter";
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
              rasi =
                import ./rofi/theme.nix
                config.theme.launcher
                "${config.theme.fonts.monospace} Italic 11";
            in
              mkDefault (pkgs.writeText "theme.rasi" rasi);
          };

          ytm = {
            stylesheetFile = mkDefault ./ytm/stylesheet.css;
          };

          zathura = {
            zathurarc =
              # zathurarc
              ''
                set recolor "true"
                set default-bg rgba(0,0,0,0.7)
                set recolor-lightcolor rgba(0,0,0,0)
                set adjust-open "width"
              '';
          };

          nixvim = {
            transparency.enable = mkDefault true;
            colors.theme = "kanagawa";
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

          wallust = {
            enable = true;
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

              bgColor = "rgba(8,8,8,${toString config.theme.win.opacity.background})";

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
                    font-size:18px;
                    font-family: "Old London";
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
                    "clock" = {
                      "format" = "{:%I:%M:%S %p} ";
                      "interval" = 1;
                      "tooltip-format" = "{calendar}";
                      "calendar" = {
                        "format" = {
                          "months" = "<span font_family='Old London' size='large'>{}</span>";
                          "weekdays" = "<span font_family='CartographCF Nerd Font'>{}</span>";
                          "days" = "<span font_family='CartographCF Nerd Font'>{}</span>";
                          "today" = "<span color='#fAfBfC'><b>{}</b></span>";
                        };
                      };
                      "actions" = {
                        "on-click-right" = "shift_down";
                        "on-click" = "shift_up";
                      };
                    };
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
                      modules-center = default.right ++ ["hyprland/workspaces"];
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
            monospace = "CartographCF Nerd Font";
            reading = "IBM Plex";
          };
          launcher = {
            # https://github.com/rebelot/kanagawa.nvim/blob/aef7f5cec0a40dbe7f3304214850c472e2264b10/lua/kanagawa/colors.lua
            background = mkDefault "#223249";
            border = mkDefault "#ff8080ee";
            background-alt = mkDefault "#1f1f28";
            foreground = mkDefault "#DCD7CA";
            selected = mkDefault "#7E9CD8";
            active = mkDefault "#98BB6C";
            urgent = mkDefault "#E46876";
          };
          win = {
            border = {
              active = "#ff000099";
              inactive = "#ff000099";
              size = 1;
            };
            shadow = {
              active = "#ff8080ee";
              inactive = "#ff808000";
              range = 5;
              render_power = 3;
            };
            opacity = {
              active = 1.0;
              inactive = 1.0;
              background = 0.9;
            };
            corners = {
              rounding = 0;
              rounding_power = 2;
            };
            blur = {
              size = 10;
              passes = 2;
              vibrancy = 0.5696;
            };
            layout = {
              gaps_in = 5;
              gaps_out = 15;
            };
          };
          term = {
            # https://github.com/dexpota/kitty-themes/blob/master/themes/IR_Black.conf
            # https://github.com/kovidgoyal/kitty-themes/blob/master/themes/kanagawa.conf
            cursor = "#7f7f7f";
            background = "#1f1f28";
            foreground = "#DCD7CA";
            selection_background = "#b4d5ff";
            selection_foreground = "#000000";
            color0 = "#4f4f4f";
            color8 = "#7b7b7b";
            color1 = "#fa6c5f";
            color9 = "#fcb6af";
            color2 = "#a8fe60";
            color10 = "#ceffab";
            color3 = "#fffeb6";
            color11 = "#fffecc";
            color4 = "#96cafd";
            color12 = "#b5dcfe";
            color5 = "#fa72fc";
            color13 = "#fb9bfe";
            color6 = "#c6c4fd";
            color14 = "#dfdffd";
            color7 = "#eeedee";
            color15 = "#fefffe";
          };

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
