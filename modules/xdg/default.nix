{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.xdg;
in {
  options.modules.xdg = {
    enable = mkEnableOption "xdg stuff";
  };

  config = mkIf cfg.enable {
    # https://home-manager-options.extranix.com/?query=xdg.portal.enable&release=release-25.11
    environment.pathsToLink = ["/share/xdg-desktop-portal" "/share/applications"];
  };
}
