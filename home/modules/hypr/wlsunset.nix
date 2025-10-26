{
  config,
  lib,
  ...
}: let
  cfg = config.modules.hypr.sunset;
in
  with lib; {
    options.modules.hypr.sunset = {
      enable = config.utils.mkEnableOption "hypr.sunset" config.modules.hypr.enable;
    };

    config = mkIf cfg.enable {
      services.wlsunset = {
        enable = true;
        gamma = 0.9;
        sunrise = "06:30";
        sunset = "20:30";
      };
    };
  }
