{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.hypr.shot;
in
  with lib; {
    options.modules.hypr.shot = {
      enable = config.utils.mkEnableOption "hypr.shot" config.modules.hypr.enable;
    };

    config = mkIf cfg.enable {
      home.packages = with pkgs; [
        hyprshot
      ];

      wayland.windowManager.hyprland.settings.bind = let
        hyprShotDir = config.vars.screenshots.dir;
        hyprshotExe = with pkgs; lib.getExe hyprshot;
        hyprshotCmd = ''HYPRSHOT_DIR="${hyprShotDir}" ${hyprshotExe} -z '';
      in [
        ", PRINT, exec, ${hyprshotCmd} -m output"
        "SUPER, PRINT, exec, ${hyprshotCmd} -m window"
        "SHIFT SUPER, PRINT, exec, ${hyprshotCmd} -m region"
      ];
    };
  }
