{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.yubi;
in {
  options.modules.yubi = {
    enable = mkEnableOption "yubikey tooling";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      yubikey-manager
      age-plugin-yubikey
    ];

    services.yubikey-agent = {
      enable = true;
    };
  };
}
