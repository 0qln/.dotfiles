{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.hypr.picker;
in
  with lib; {
    options.modules.hypr.picker = {
      enable = config.utils.mkEnableOption "hypr.picker" config.modules.hypr.enable;
    };

    config = mkIf cfg.enable {
      home.packages = with pkgs; [
        hyprpicker
      ];
    };
  }
