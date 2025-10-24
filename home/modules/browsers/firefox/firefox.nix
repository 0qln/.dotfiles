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
      setDefault = mkEnableOption "set default browser";
    };
    config = mkIf cfg.enable {
      modules.browser._xdgDefault = mkDefault "firefox.desktop";

      programs.firefox = {
        enable = true;
      };
    };
  }
