{
  config,
  lib,
  ...
}: let
  monitors = config.vars.monitors.devices;
  cfg = config.modules.wallpaperengine;
in
  with lib; {
    options.modules.wallpaperengine = {
      enable = mkEnableOption "wallpaperengine";
    };

    config = mkIf cfg.enable {
      # docs:
      # https://home-manager-options.extranix.com/?query=linux-wallpaperengine&release=release-25.05
      # https://mynixos.com/home-manager/options/services.linux-wallpaperengine
      # https://github.com/Almamu/linux-wallpaperengine

      # in case i am also as lost as this dud:
      # https://discourse.nixos.org/t/how-is-linux-wallpaperengine-supposed-to-work-on-nixos/37126/6

      services.linux-wallpaperengine = {
        enable = true;
        wallpapers = [
          {
            monitor = monitors.center.name;
            wallpaperId = "3549235003";
          }
        ];
      };
    };
  }
