{
  inputs,
  self,
  ...
}: let
  name = "foggy-forest-1";
  hyprlockColors = "~/.config/hypr/hyprlock-colors.conf";
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
          wallpapers = let
            mapping = {
              "-" = [
                {
                  monitor = monitors.devices.center.name;
                  wallpaperId = "2142532648";
                  scaling = "fill";
                  audio.silent = true;
                  fullscreen.pause = true;
                }
              ];
              "|-|" = [
                {
                  screenSpan = with monitors.devices; [
                    left.name
                    center.name
                    right.name
                  ];
                  wallpaperId = "2142532648";
                  scaling = "fill";
                  audio.silent = true;
                  # don't pause on fullscreen if we have more than just the center monitor
                  fullscreen.pause = false;
                }
              ];
            };
          in
            mapping.${monitors.arrangement.byPictogram};
        };

        modules = {
          waybar.enable = mkDefault true;
          hyprshot.enable = mkDefault true;
          hyprpicker.enable = mkDefault true;
          hyprlock.enable = mkDefault true;
          hyprland.enable = mkDefault true;

          dunst = {
            enable = mkDefault true;
            settings = {
              global = {
                transparency = 0;
                font = "${config.theme.fonts.monospace} 11";
              };
            };
          };

          cursor = {
            cursor = mkDefault "frieren-winter";
          };

          fonts = {
            cartograph-cf.enable = mkDefault true; # general monospace
            angel-wish.enable = mkDefault true; # cosmetic
            ruritania.enable = mkDefault true; # cosmetic
            kingjola.enable = mkDefault true; # cosmetic
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
              walName = "wallhaven-q6wyg7.jpg";
              rawImg = "${pkgs.fetchurl {
                url = "https://w.wallhaven.cc/full/q6/${walName}";
                hash = "sha256-ClK5aTven8j+/DWoQ4YAMGoAF48ojFXl95NT2Z3WPIQ=";
              }}";
              # todo: figure out exact size we need
              # scaling down the bg image, otherwise it takes like 500ms to load
              img = utils.resizeImage 1000 1000 rawImg walName;
              rasi =
                import ./rofi/theme.nix
                "${img}/share/${walName}"
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
                set default-bg rgba(8,8,8,${toString config.theme.win.opacity.background})
                set recolor-lightcolor rgba(0,0,0,0)
                set adjust-open "width"
              '';
          };

          nixvim = {
            transparency.enable = mkDefault true;
            colors = {
              theme = "sora";
              highlight.indent = "rainbow.lua";
            };
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
            theme = "midnight-tokyo-night";
          };

          wallust = {
            enable = true;
            wallpaper = "${pkgs.fetchurl {
              url = "https://w.wallhaven.cc/full/83/wallhaven-83p31k.jpg";
              hash = "sha256-6+Shpm+xpEW11IGujgMKKlo3INur7n6O+AdZLUJWJTA=";
            }}";
            settings = {
              backend = "fastresize";
              color_space = "lch";
              palette = "dark";
              templates = {
                waybar = {
                  template = "waybar.css";
                  target = "~/.config/waybar/colors.css";
                };
                dunst = {
                  template = "dunstrc";
                  target = "~/.config/dunst/dunstrc.d/00_wallust.conf";
                };
                hyprlock = {
                  template = "hyprlock-colors.conf";
                  target = hyprlockColors;
                };
                rofi = {
                  template = "rofi-colors.rasi";
                  target = "~/.config/rofi/colors.rasi";
                };
              };
            };
          };

          wallpaperengine.enable = true;
        };

        programs.hyprlock = let
          escape =
            replaceStrings
            ["#" ''"'']
            ["##" ''\"''];

          # give the text a rise up and down such that the bounding boxes dont clip any fance parts of extravagant fonts.
          renderFancyFont = text: "<span rise='30000'> </span> ${text} <span rise='-30000'> </span>";
        in {
          # inspiration: https://www.hyprflux.dev/features/hyprlock.html#features
          settings = {
            # Source the colors generated by Wallust
            source = "~/.config/hypr/hyprlock-colors.conf";

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
                k: v: {
                  monitor = v.name;
                  path = toString wals.${k};
                  crossfade_time = 1.0;
                }
              )
              devs;

            # vignette with dither pattern
            image = let
              monitor = monitors.devices.center;
              inherit (monitor.dim) w h;

              lesserSide =
                if w < h
                then w
                else h;

              ditherVignette =
                pkgs.runCommand "dither-vignette.png" {
                  nativeBuildInputs = [pkgs.imagemagick];
                } ''
                  # Generate a radial gradient, apply ordered dithering (8x8 matrix),
                  # and make the bright center transparent so only edge dots remain.
                  magick -size ${toString w}x${toString h} radial-gradient:white-black \
                    -ordered-dither o8x8 \
                    -transparent white \
                    $out
                '';
            in [
              {
                monitor = monitor.name;
                path = "${ditherVignette}";
                size = lesserSide;
                rounding = 0;
                border_size = 0;
                position = "0, 0";
                halign = "center";
                valign = "center";
                zindex = 0;
              }
            ];

            input-field = [
              {
                monitor = monitors.devices.center.name;
                size = "340, 55";

                rounding = 0;
                outline_thickness = 1;
                position = "0, -40";
                halign = "center";
                valign = "center";

                font_family = "Kingjola";
                dots_text_format = "x";
                font_color = "$color14";

                dots_size = 0.45;
                dots_spacing = 0.2;
                dots_center = true;

                inner_color = "$background_rgba";
                outer_color = "$color12";

                shadow_passes = 3;
                shadow_size = 10;
                shadow_color = "$color14";
                shadow_boost = 2.0;

                check_color = "$color13";
                fail_color = "rgb(180, 45, 45)";
                capslock_color = "$color12";

                fade_on_empty = false;
                placeholder_text = ''<i><span font_family="Ruritania" foreground="$color6_raw">Sssdfg...</span></i>'';
                fail_text = ''<i><span foreground="##ff6b6b"><b>$FAIL</b> ($ATTEMPTS)</span></i>'';
              }
            ];

            label = [
              # --- 1. TIME: NEON AURA (BACK LAYER) ---
              {
                monitor = monitors.devices.center.name;
                text = ''cmd[update:1000] echo "${renderFancyFont ''$(date +"%I:%M")''}"'';
                color = "$color12"; # Wallust bright accent (or $color14 / $color4)
                font_size = 210;
                font_family = "Angel wish";
                position = "0, 230";
                halign = "center";
                valign = "center";
                zindex = 0;

                # Deep multi-pass shadow radiates the bright accent color outward
                shadow_passes = 5;
                shadow_size = 16;
                shadow_color = "$color12";
                shadow_boost = 3.5;
              }

              # --- 2. TIME: WHITE-HOT CORE (FRONT LAYER) ---
              {
                monitor = monitors.devices.center.name;
                text = ''cmd[update:1000] echo "${renderFancyFont ''$(date +"%I:%M")''}"'';
                color = "$foreground"; # Crisp white-hot center (rgb(ECF5F3))
                font_size = 210;
                font_family = "Angel wish";
                position = "0, 230";
                halign = "center";
                valign = "center";
                zindex = 1;

                # Tight inner halo that makes the text strokes look illuminated
                shadow_passes = 2;
                shadow_size = 4;
                shadow_color = "$foreground";
                shadow_boost = 2.0;
              }

              # --- 3. DATE DISPLAY ---
              {
                monitor = monitors.devices.center.name;
                text = ''cmd[update:1000] echo -e "${renderFancyFont ''$(LC_TIME=en_US.UTF-8 date +"%A, %B %d")''}"'';
                color = "$foreground";
                font_size = 30;
                font_family = "Ruritania";
                position = "0, 80";
                halign = "center";
                valign = "center";
                shadow_passes = 2;
                shadow_size = 4;
                shadow_color = "$color12";
              }

              # --- 4. SONG INFORMATION ---
              {
                monitor = monitors.devices.center.name;
                text = let
                  script = "${pkgs.writeShellScript "songdetails" ''
                    if command -v playerctl &> /dev/null; then
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
                  text = ''<span> $(${script}) </span>'';
                in ''cmd[update:1000] echo "${text |> escape |> renderFancyFont}"'';
                color = "$foreground";
                shadow_size = 2;
                shadow_passes = 2;
                shadow_color = "$color12";
                font_size = 20;
                font_family = "Angel wish";
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
                inherit (config.modules.waybar) left center right;
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
              inactive = "${config.theme.term.color4}aa";
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
              size = 4;
              passes = 3;
              vibrancy = 1.0;
            };
            layout = {
              gaps_in = 10;
              gaps_out = 15;
            };
          };
          term = let
            conf = builtins.readFile ./kitty/${"Moonfly.conf"};
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
            # todo: some opengl error when exporting the WPE image as screenshot, replace those when it works
            images = {
              left = "${./wpe-1512181248_left.png}";
              right = "${./wpe-1512181248_right.png}";
              center = "${pkgs.fetchurl {
                url = "https://w.wallhaven.cc/full/0q/wallhaven-0qw55l.jpg";
                hash = "sha256-VD8nwfOXVXlgJKcO04mpsF4QdE4GrlgulA6nhkYmpJg=";
              }}";
              normal = "${pkgs.fetchurl {
                url = "https://w.wallhaven.cc/full/0q/wallhaven-0qw55l.jpg";
                hash = "sha256-VD8nwfOXVXlgJKcO04mpsF4QdE4GrlgulA6nhkYmpJg=";
              }}";
            };
          };
        };
      };
    };
  }
