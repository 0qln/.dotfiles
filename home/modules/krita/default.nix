{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.krita;
in {
  options.modules.krita = {
    enable = mkEnableOption "krita drawing program";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      krita
    ];
  };
}
