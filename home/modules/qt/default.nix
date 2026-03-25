{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.qt;
in {
  options.modules.qt = {
    enable = mkEnableOption "Qt theming";
  };
  config = mkIf cfg.enable {
    qt = {
      enable = true;
      style = mkIf (config.theme.mode == "dark") {
        package = pkgs.adwaita-qt;
        name = "adwaita-dark";
      };
    };
  };
}
