{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.postman;
in
  with lib; {
    options.modules.postman = {
      enable = mkEnableOption "postman";
    };

    config = mkIf cfg.enable {
      home.packages = with pkgs; [
        postman
      ];
    };
  }
