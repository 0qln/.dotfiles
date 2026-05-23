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
      modules.browser._xdgDefault = mkIf cfg.setDefault (mkDefault "firefox.desktop");

      programs.firefox = {
        enable = true;
        configPath = "${config.xdg.configHome}/mozilla/firefox";
      };
    };
  }
