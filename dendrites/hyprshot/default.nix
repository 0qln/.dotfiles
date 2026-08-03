{...}: {
  flake.homeModules.hyprshot = {
    pkgs,
    config,
    lib,
    ...
  }: let
    cfg = config.modules.hyprshot;
  in
    with lib; {
      options.modules.hyprshot = {
        enable = mkEnableOption "hyprshot";
      };

      config = mkIf cfg.enable {
        home.packages = with pkgs; [
          hyprshot
        ];
        wayland.windowManager.hyprland.settings = let
          hyprShotDir = config.vars.screenshots.dir;
          hyprshotExe = with pkgs; lib.getExe hyprshot;
          hyprshotCmd = ''HYPRSHOT_DIR="${hyprShotDir}" ${hyprshotExe} -z '';
          inherit (config.utils.hyprLua) exec bindl;
        in {
          bind = [
            # for normal laptops that have a print button
            (bindl "PRINT" (exec "${hyprshotCmd} -m output"))
            (bindl "SUPER + PRINT" (exec "${hyprshotCmd} -m window"))
            (bindl "SHIFT + SUPER + PRINT" (exec "${hyprshotCmd} -m region"))

            # for goofy ahh laptop keyboard that has an imposter on the keyboard >:3
            (bindl "SUPER + SHIFT + s" (exec "${hyprshotCmd} -m output"))
            (bindl "SUPER + SHIFT + ALT + s" (exec "${hyprshotCmd} -m window"))
            (bindl "SUPER + SHIFT + ALT + CTRL + s" (exec "${hyprshotCmd} -m region"))
          ];
        };
      };
    };
}
