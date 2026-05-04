{inputs, ...}:
with inputs.nixpkgs.lib; {
  flake.homeModules.wlsunset = {config, ...}: let
    cfg = config.modules.wlsunset;
  in {
    options.modules.wlsunset = {
      enable = mkEnableOption "wlsunset";
    };

    config = mkIf cfg.enable {
      services.wlsunset = {
        enable = true;
        gamma = 0.9;
        sunrise = "06:30";
        sunset = "20:30";
      };
    };
  };
}
