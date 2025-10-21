{
  config,
  lib,
  ...
}: let
  inherit (config.vars) monitors;
  cfg = config.modules.hypr.bar;
in
  with lib; {
    options.modules.hypr.bar = {
      enable = config.utils.mkEnableOption "hypr.bar" config.modules.hypr.enable;
    };

    # docs:
    # waybar in nix:
    #   - https://mynixos.com/home-manager/option/programs.waybar.settings
    # waybar general:
    #   - https://github.com/Alexays/Waybar/wiki/Configuration
    # templating syntax:
    #   - https://docs.gtk.org/Pango/pango_markup.html#pango-markup
    # inspiration
    #   - https://github.com/Alexays/Waybar/blob/master/resources/config.jsonc
    #   - https://github.com/RoastBeefer00/nix-home/blob/main/nix_modules/waybar.nix
    #   - https://gitlab.com/Zaney/zaneyos/-/tree/main/modules/home/waybar?ref_type=heads
    config = mkIf cfg.enable {
      programs.waybar = {
        enable = true;
        style = ./waybar.css;
        settings = [
          {
            name = "barRight";
            layer = "top";
            position = "top";
            height = 30;
            output = [
              monitors.devices.right.name
            ];
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
            output = [
              monitors.devices.left.name
            ];
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
  }
