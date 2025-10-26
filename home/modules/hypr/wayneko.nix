{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.hypr.wayneko;
in
  with lib; {
    options.modules.hypr.wayneko = {
      enable = config.utils.mkEnableOption "wayneko" config.modules.hypr.enable;
    };

    config = mkIf cfg.enable {
      home.packages = with pkgs; [
        wayneko
      ];

      #todo: systemd service to spawn one and his friend :)
      # wayneko --layer top --follow-pointer true --type neko --sleepiness 2 &
      #
      # maybe with random sleepiness ?
    };
  }
