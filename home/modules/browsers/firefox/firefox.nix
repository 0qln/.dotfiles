{
  config,
  lib,
  ...
}: let
  cfg = config.modules.browser.firefox.firefox;
in
  with lib; {
    options.modules.browser.firefox.firefox = {
      enable = mkEnableOption "firefox";
    };
    config = mkIf cfg.enable {
      programs.firefox = {
        enable = true;
      };
    };
  }
