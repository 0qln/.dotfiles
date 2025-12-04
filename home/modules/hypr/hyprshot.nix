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
      wayland.windowManager.hyprland.settings = let
        hyprShotDir = config.vars.screenshots.dir;
        hyprshotExe = with pkgs; lib.getExe hyprshot;
        hyprshotCmd = ''HYPRSHOT_DIR="${hyprShotDir}" ${hyprshotExe} -z '';
      in {
        bind = [
          # for normal laptops that have a print button
          ", PRINT, exec, ${hyprshotCmd} -m output"
          "SUPER, PRINT, exec, ${hyprshotCmd} -m window"
          "SHIFT SUPER, PRINT, exec, ${hyprshotCmd} -m region"
        ];
        binds = [
          # for goofy ahh laptop keyboard that has an imposter on the keyboard >:3
          "SHIFT_R & SUPER_L, S, exec, ${hyprshotCmd} -m output"
          "SHIFT_R & SUPER_L & SHIFT_L, S, exec, ${hyprshotCmd} -m window"
          "SHIFT_R & SUPER_L & SHIFT_L & ALT_L, S, exec, ${hyprshotCmd} -m region"
        ];
      };
    };
  }
