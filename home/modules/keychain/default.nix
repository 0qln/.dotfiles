{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.keychain;
in {
  options.modules.keychain = {
    enable = mkEnableOption "keychain";
  };

  config = mkIf cfg.enable {
    programs.keychain = {
      enable = true;
    };
  };
}
