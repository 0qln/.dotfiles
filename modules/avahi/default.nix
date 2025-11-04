{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.avahi;
in {
  options.modules.avahi = {
    enable = mkEnableOption "avahi";
  };

  config = mkIf cfg.enable {
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        addresses = true;
      };
    };
  };
}
