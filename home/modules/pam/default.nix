{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.pam;
in {
  options.modules.pam = {
    enable = mkEnableOption "pam";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [libsecret];

    services.gnome-keyring.enable = true;
    services.gnome-keyring.components = [
      "pkcs11"
      "secrets"
      "ssh"
    ];

    programs.keychain = {
      enable = true;
      keys = []; # set empty, since the default is id_rsa and we don't want that
    };
  };
}
