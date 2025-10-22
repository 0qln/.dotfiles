{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.theme;
  name = builtins.dirOf __curPos.file;
in
  with lib; {
    config = mkIf cfg."enable_${name}" {
      modules = {
        cursor = {
          cursor = mkDefault "frieren-winter";
        };
        fonts = {
          #TODO: enable "CartographCF Nerd Font" once the module is refactored
        };
        terminal = {
          emulator = mkDefault "kitty";
          font = mkDefault "CartographCF Nerd Font";
          backgroundOpacity = mkDefault 0.7;
          kitty = {
            themeFile = mkDefault "IR_Black";
          };
        };
        rofi = {
          enable = mkDefault true;
          theme = mkDefault ./rofi;
        };
        ytm = {
          stylesheetPath = mkDefault ./ytm/stylesheet.css;
        };
        zathura = {
          zathurarcFile = mkDefault ./zathura/zathurarc;
        };
      };
      theme = {
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
