{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.nixvim;
in {
  options.modules.nixvim = {
    wayland.enable = mkEnableOption "wayland clipboard integration";
  };
  config = mkIf cfg.wayland.enable {
    programs.nixvim = {
      clipboard = {
        providers.wl-copy.enable = config.modules.hypr.enable;
      };
    };
  };
}
