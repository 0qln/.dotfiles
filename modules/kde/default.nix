{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.kde;
in {
  options.modules.kde = {
    enable = mkEnableOption "kde plasma6";
  };

  # https://wiki.nixos.org/wiki/KDE
  config = mkIf cfg.enable {
    services = {
      xserver.enable = true;
      displayManager.sddm.enable = true;
      desktopManager.plasma6.enable = true;
      displayManager.sddm.settings.General.DisplayServer = "wayland";
      displayManager.sddm.wayland.enable = true;
    };
  };
}
