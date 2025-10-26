{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.browser.firefox.tor;
in
  with lib; {
    options.modules.browser.firefox.tor = {
      enable = mkEnableOption "tor";
    };
    config = mkIf cfg.enable {
      home.packages = with pkgs; [
        tor-browser
      ];
    };
  }
