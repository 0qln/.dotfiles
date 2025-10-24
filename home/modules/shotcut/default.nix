{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.shotcut;
in {
  options.modules.shotcut = {
    enable = mkEnableOption "shotcut video editing software";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      shotcut
    ];
  };
}
