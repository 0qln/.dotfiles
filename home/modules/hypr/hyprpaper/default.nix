{
  config,
  lib,
  ...
}: let
  cfg = config.modules.hypr.paper;
in
  with lib; {
    options.modules.hypr.paper = {
      enable = config.utils.mkEnableOption "hypr.paper" config.modules.hypr.enable;
    };

    config = mkIf cfg.enable {
      services.hyprpaper = let
        mons = config.vars.monitors;
        wals = config.theme.wallpapers.arrangements.${mons.arrangement.byPictogram};
        imgs = config.theme.wallpapers.images;
        devs = mons.devices;
      in {
        enable = true;
        settings = {
          ipc = "on";
          preload = lib.attrsets.attrValues imgs;
          wallpaper =
            lib.attrsets.mapAttrsToList (
              k: v:
                if (hasAttr k wals)
                then "${v.name}, ${wals.${k}}"
                else throw "wallpaper for ${k} monitor '${v.name}' is missing."
            )
            devs;
        };
      };
    };
  }
