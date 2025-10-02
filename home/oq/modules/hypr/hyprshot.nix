{
  pkgs,
  vars,
  config,
  ...
}: let
  home = vars.home config.home.homeDirectory;
  hyprShotDir = home.screenshots.dir;
  hyprshotExe = with pkgs; lib.getExe hyprshot;
  hyprshotCmd = ''HYPRSHOT_DIR="${hyprShotDir}" ${hyprshotExe} -z '';
in {
  home.packages = with pkgs; [
    hyprshot
  ];

  wayland.windowManager.hyprland.settings.bind = [
    ", PRINT, exec, ${hyprshotCmd} -m output"
    "SUPER, PRINT, exec, ${hyprshotCmd} -m window"
    "SHIFT SUPER, PRINT, exec, ${hyprshotCmd} -m region"
  ];
}
