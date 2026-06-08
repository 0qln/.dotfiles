{inputs, ...}: let
  name = "windows-terminal-1";
in
  with inputs.nixpkgs.lib; {
    flake.homeModules."themes/${name}" = {
      pkgs,
      config,
      ...
    }: let
      cfg = config.themes.${name};
    in {
      options.themes.${name} = {
        enable = mkEnableOption "[Theme] ${name}";
      };

      config = mkIf cfg.enable {
        modules = {
          nixvim = {
            transparency.enable = mkDefault true;
            colors = {
              theme = "monokai-pro";
              highlight.indent = "rainbow.lua";
            };
          };

          wallust = {
            enable = true;
            wallpaper = "${pkgs.fetchurl {
              url = "https://w.wallhaven.cc/full/qz/wallhaven-qzdolr.jpg";
              hash = "sha256-cMukjrUSx4B24hBt5r6mbEiO5ErfEW2233ptyp6yBUE=";
            }}";
            settings = {
              backend = "fastresize";
              color_space = "lch";
              palette = "dark";
              templates = {};
            };
          };
        };
      };
    };
  }
