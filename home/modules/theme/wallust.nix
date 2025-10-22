{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.wallust;
in {
  options.modules.wallust = {
    enable = mkEnableOption "wallust";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      wallust
    ];
  };
}
