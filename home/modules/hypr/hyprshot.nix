{
  pkgs,
  vars,
  config,
  lib,
  ...
}: let
  cfg = config.modules.hypr.shot;
in
  with lib; {
    options.modules.hypr.shot = {
      enable = mkOption {
        default = config.modules.hypr.enable;
        example = false;
        description = "Whether to enable ${"hypr.shot"}.";
        type = lib.types.bool;
      };
    };

    config = mkIf cfg.enable {
      home.packages = with pkgs; [
        hyprshot
      ];

      wayland.windowManager.hyprland.settings.bind = let
        home = vars.home config.home.homeDirectory;
        hyprShotDir = home.screenshots.dir;
        hyprshotExe = with pkgs; lib.getExe hyprshot;
        hyprshotCmd = ''HYPRSHOT_DIR="${hyprShotDir}" ${hyprshotExe} -z '';
      in [
        ", PRINT, exec, ${hyprshotCmd} -m output"
        "SUPER, PRINT, exec, ${hyprshotCmd} -m window"
        "SHIFT SUPER, PRINT, exec, ${hyprshotCmd} -m region"
      ];
    };
  }
