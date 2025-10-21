{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.msteams;
in
  with lib; {
    options.modules.msteams = {
      enable = mkEnableOption "msteams";
    };

    config = mkIf cfg.enable {
      home.packages = with pkgs; [
        teams-for-linux
      ];
    };
  }
