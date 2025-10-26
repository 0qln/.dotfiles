{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.kooha;
in
  with lib; {
    options.modules.kooha = {
      enable = mkEnableOption "kooha";
    };
    config = mkIf cfg.enable {
      home.packages = with pkgs; [
        kooha # video recording
      ];
    };
  }
