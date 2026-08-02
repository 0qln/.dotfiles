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
          inherit (config.utils.hyprLua) exec bind;
        in {
          bind = [
            # for normal laptops that have a print button
            (bind "PRINT" (exec "${hyprshotCmd} -m output"))
            (bind "SUPER + PRINT" (exec "${hyprshotCmd} -m window"))
            (bind "SHIFT + SUPER + PRINT" (exec "${hyprshotCmd} -m region"))

            # for goofy ahh laptop keyboard that has an imposter on the keyboard >:3
            # NOTE (hyprlang->lua migration): these previously used the `&`
            # multi-held-key chord syntax, which has no documented lua equivalent.
            # Translated to `+`-joined keysyms as a best effort; verify on device.
            (bind "SHIFT_R + SUPER_L + S" (exec "${hyprshotCmd} -m output"))
            (bind "SHIFT_R + SUPER_L + SHIFT_L + S" (exec "${hyprshotCmd} -m window"))
            (bind "SHIFT_R + SUPER_L + SHIFT_L + ALT_L + S" (exec "${hyprshotCmd} -m region"))
          ];
        };
      };
    };
}
