args @ {
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.libreoffice;
in
  with lib; {
    options.modules.libreoffice = {
      enable = mkEnableOption "libreoffice";
    };

    config = mkIf cfg.enable {
      home.packages = [pkgs.libreoffice-qt] ++ (import ./spellcheck.nix args);
    };
  }
