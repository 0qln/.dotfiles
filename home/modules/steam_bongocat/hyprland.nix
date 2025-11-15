{
  lib,
  config,
  ...
}: let
  cfg = config.modules.hypr.land;
  steam_id = import ./steam_id.nix;
  inherit (config.vars) monitors;
  gaps_out = toString config.theme.win.layout.gaps_out;
in
  with lib; {
    config = mkIf cfg.enable {
      modules.hypr.land.input = {
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
        workspace = [
          "${steam_id}, monitor:${monitors.devices.right.name}"
          "${steam_id}, gapsout:1500 ${gaps_out} ${gaps_out} ${gaps_out}"
        ];
        windowrule = [
          "tag +steam_bongocat, class:^(steam_app_${steam_id})$, title:^(BongoCat)$"
          "workspace ${steam_id}, tag:steam_bongocat"
          "fullscreenstate 1, tag:steam_bongocat" # maximize
        ];
      };
    };
  }
