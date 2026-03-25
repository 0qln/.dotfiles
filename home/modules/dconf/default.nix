{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.dconf;
in {
  options.modules.dconf = {
    enable = mkEnableOption "enable dconf support";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      dconf
    ];

    dconf = {
      enable = true;
    };
  };
}
