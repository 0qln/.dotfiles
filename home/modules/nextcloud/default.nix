{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.nextcloud;
in
  with lib; {
    options.modules.nextcloud = {
      enable = mkEnableOption "nextcloud";
    };

    config = mkIf cfg.enable {
      home.packages = with pkgs; [
        nextcloud-client
      ];

      services.nextcloud-client = {
        enable = true;
        startInBackground = true;
      };
    };
  }
