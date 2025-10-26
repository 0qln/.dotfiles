{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.zoom;
in
  with lib; {
    options.modules.zoom.enable = mkEnableOption "zoom";
    config = mkIf cfg.enable {
      home.packages = with pkgs; [
        zoom-us
      ];
    };
  }
