{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.hypr.lock;
in {
  options.modules.hypr.lock = {
    enable = config.utils.mkEnableOption "hypr.lock" config.modules.hypr.enable;
    autostart = mkEnableOption "automatically execute on startup";
  };

  config = let
    inherit (config.modules.hypr.land.input) mainMod;
    inherit (config.vars) monitors;
  in
    mkIf cfg.enable {
      # https://home-manager-options.extranix.com/?query=programs.hyprlock.enable&release=release-25.11
      programs.hyprlock = {
        enable = true;
        settings = {
          background = mkDefault [
            {
              path = "screenshot";
              blur_passes = 3;
              blur_size = 8;
            }
          ];

          input-field = mkDefault [
            {
              fade_on_empty = false;
              monitor = monitors.devices.center.name;
            }
          ];
        };
      };

      wayland.windowManager.hyprland = {
        settings = {
          bind = mkMerge [
            [
              "${mainMod}, L, exec, hyprlock"
            ]
          ];

          exec-once = mkMerge [
            (mkIf cfg.autostart ["hyprlock || hyprctl dispatch exit"])
          ];
        };
      };
    };
}
