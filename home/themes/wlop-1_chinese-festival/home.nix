{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  name = import ./name.nix;
  cfg = config.themes.${name};
  inherit (config.vars) monitors;
in {
  config = mkIf cfg.enable {
    modules = {
      cursor = {
        cursor = mkDefault "frieren-winter";
      };
      fonts = {
        cartograph-cf.enable = mkDefault true; # general monospace
        ibm-plex.enable = mkDefault true; # obsidian
      };
      terminal = {
        emulator = mkDefault "kitty";
        backgroundOpacity = mkDefault 0.9;
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
    };
    programs = {
      waybar = {
        settings = [
          {
            name = "barRight";
            layer = "top";
            position = "top";
            height = 30;
            output = [monitors.devices.right.name];
            modules-left = [
            ];
            modules-center = [
            ];
            modules-right = [
              "clock"
            ];
          }
          {
            name = "barLeft";
            layer = "top";
            position = "top";
            height = 30;
            output = [monitors.devices.left.name];
            modules-left = [
            ];
            modules-center = [
            ];
            modules-right = [
            ];
          }
        ];
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
}
