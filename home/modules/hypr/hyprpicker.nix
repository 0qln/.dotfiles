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
      enable = mkOption {
        default = config.modules.hypr.enable;
        example = false;
        description = "Whether to enable ${"hypr.picker"}.";
        type = lib.types.bool;
      };
    };

    config = mkIf cfg.enable {
      home.packages = with pkgs; [
        hyprpicker
      ];
    };
  }
