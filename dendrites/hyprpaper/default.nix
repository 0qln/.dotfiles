{...}: {
  flake.homeModules.hyprpaper = {
    config,
    lib,
    ...
  }: let
    cfg = config.modules.hyprpaper;
  in
    with lib; {
      options.modules.hyprpaper = {
        enable = mkEnableOption "hyprpaper";
        autostart = config.utils.mkEnableOption "automatically execute on startup" cfg.enable;
      };

      config = let
        mons = config.vars.monitors;
        wals = config.theme.wallpapers.arrangements.${mons.arrangement.byPictogram};
        imgs = config.theme.wallpapers.images;
        devs = mons.devices;
      in
        mkIf cfg.enable {
          # this service is not up to date with current syntax so im rolling my own shit.
          # https://bbs.archlinux.org/viewtopic.php?id=311381
          # services.hyprpaper = {
          #   enable = true;
          #   settings = {
          #     ipc = "on";
          #   };
          # };
          home.file.".config/hypr/hyprpaper.conf".text = let
            preload = map (img: "preload = ${img}") (lib.attrsets.attrValues imgs);
            wallpapers =
              lib.attrsets.mapAttrsToList (
                k: v:
                  if (hasAttr k wals)
                  then # hyprlang
                    ''
                      wallpaper {
                        monitor = ${v.name}
                        path = ${wals.${k}}
                        fit_mode = cover
                      }
                    ''
                  else throw "wallpaper for ${k} monitor '${v.name}' is missing."
              )
              devs;
            settings = [
              "ipc = on"
              "splash = false"
            ];
            config = concatStringsSep "\n" (preload ++ wallpapers ++ settings);
          in
            mkForce config;

          wayland.windowManager.hyprland = {
            settings = {
              on = mkIf cfg.autostart [
                {
                  _args = [
                    "hyprland.start"
                    (config.utils.hyprLua.inline ''function() hl.exec_cmd("hyprpaper") end'')
                  ];
                }
              ];
            };
          };
        };
    };
}
