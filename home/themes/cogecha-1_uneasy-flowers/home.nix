{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  name = import ./name.nix;
  cfg = config.themes.${name};
in {
  config = mkIf cfg.enable {
    modules = {
      cursor = {
        cursor = mkDefault "maomao"; #maomao
      };
      fonts = {
        cartograph-cf.enable = mkDefault true; # general monospace
        ibm-plex.enable = mkDefault true; # obsidian
      };
      terminal = {
        emulator = mkDefault "kitty";
        backgroundOpacity = mkDefault 0.7;
      };
      rofi = {
        enable = mkDefault true;
        themeFile = mkDefault (pkgs.writeText "theme.rasi" (import ./rofi/theme.nix config.theme.launcher));
      };
      ytm = {
        stylesheetFile = mkDefault ./ytm/stylesheet.css;
      };
      zathura = {
        zathurarcFile = mkDefault ./zathura/zathurarc;
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
          active = "#9da9a000";
          inactive = "#85928900";
          size = 0;
        };
        shadow = {
          active = "#9da9a0ff";
          inactive = "#ff808000";
          range = 5;
          render_power = 3;
        };
        opacity = {
          active = 1.0;
          inactive = 1.0;
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
          vert1 = "${pkgs.fetchurl {
            url = "https://w.wallhaven.cc/full/ex/wallhaven-exj8jl.jpg";
            hash = "sha256-sC6gYIAgTlFNFdn9dbvPj3ZQ6u6KGX5ImyHRU/BZ2bw=";
          }}";
          vert2 = "${pkgs.fetchurl {
            url = "https://w.wallhaven.cc/full/o3/wallhaven-o3k6ol.jpg";
            hash = "sha256-g5XH8n+rZnr1fw2YifqzxWJto8UeBo3VBOPYyrGxgtg=";
          }}";
          horz1 = "${pkgs.fetchurl {
            url = "https://w.wallhaven.cc/full/qr/wallhaven-qr2dxr.jpg";
            hash = "sha256-Sca+LBBAVS7xFjhO24dwsAHs9vqoqMZb6Ce4yF15BqM=";
          }}";
          horz2 = "${pkgs.fetchurl {
            url = "https://w.wallhaven.cc/full/6l/wallhaven-6lo8w6.png";
            hash = "sha256-tGHSZEPIRagf1IG4henexc+HJ1vnZWWdE5Fc3n6LUt0=";
          }}";
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

