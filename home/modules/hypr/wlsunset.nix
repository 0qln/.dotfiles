{
  config,
  lib,
  ...
}: let
  cfg = config.modules.hypr.sunset;
in
  with lib; {
    options.modules.hypr.sunset = {
      enable = mkOption {
        default = config.modules.hypr.enable;
        example = false;
        description = "Whether to enable ${"hypr.sunset"}.";
        type = lib.types.bool;
      };
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
