{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.pam;
in {
  options.modules.pam = {
    enable = mkEnableOption "pam configuration";
  };

  config = mkIf cfg.enable {
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.sddm.enableGnomeKeyring = true;
    security.pam.services.login.enableGnomeKeyring = true;
  };
}
