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
    compositor = mkOption {
      type = types.enum ["x11" "wayland"];
      default = "wayland";
    };
  };

  # https://wiki.nixos.org/wiki/KDE
  config = mkIf cfg.enable (mkMerge [
    {
      services = {
        xserver.enable = true;
        displayManager.sddm.enable = true;
        desktopManager.plasma6.enable = true;
      };
    }
    (mkIf (cfg.compositor == "x11") {
      services.displayManager.sddm.settings.General.DisplayServer = "x11-user";
      services.displayManager.defaultSession = "plasmax11";
    })
    (mkIf (cfg.compositor == "wayland") {
      services.displayManager.sddm.settings.General.DisplayServer = "wayland";
      services.displayManager.sddm.wayland.enable = true;
    })
  ]);
}
