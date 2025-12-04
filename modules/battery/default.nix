{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.battery;
in {
  options.modules.battery = {
    enable = mkEnableOption "battery related stuff";
  };

  config = mkIf cfg.enable {
    services.upower = {
      enable = true;
    };

    services.tlp = {
      enable = true;
    };
  };
}
