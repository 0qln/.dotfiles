{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.nginx;
in {
  options.modules.nginx = {
    enable = mkEnableOption "nginx";
  };

  config = mkIf cfg.enable {
    services.nginx = {
      clientMaxBodySize = "1024m";
    };
  };
}
