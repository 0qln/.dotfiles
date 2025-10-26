{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.obs;
in {
  options.modules.obs = {
    enable = mkEnableOption "obs-studio";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      obs-studio
    ];
  };
}
