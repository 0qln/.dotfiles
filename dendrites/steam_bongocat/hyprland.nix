{
  lib,
  config,
  ...
}: let
  cfg = config.modules.hyprland;
  steam_id = import ./steam_id.nix;
  inherit (config.vars) monitors;
  gaps_out = toString config.theme.win.layout.gaps_out;
in
  with lib; {
    config = mkIf cfg.enable {
      modules.hyprland.input = {
        submaps = {
          "workspace".binds = [
            {
              keys = ", b";
              dispatch = "workspace ${steam_id}";
              reset = true;
            }
          ];
        };
      };
      wayland.windowManager.hyprland.settings = {
        workspace = let
          mapping = {
            "-" = ["${steam_id}, monitor:${monitors.devices.center.name}"];
            "|-|" = ["${steam_id}, monitor:${monitors.devices.right.name}"];
          };
        in
          mkMerge [
            mapping.${monitors.arrangement.byPictogram}
            ["${steam_id}, gapsout:1500 ${gaps_out} ${gaps_out} ${gaps_out}"]
          ];
        windowrule = [
          "match:class ^(steam_app_${steam_id})$, match:title ^(BongoCat)$, tag +steam_bongocat"
          "match:tag steam_bongocat, workspace ${steam_id}"
          "match:tag steam_bongocat, fullscreen_state 1" # maximize
        ];
      };
    };
  }
