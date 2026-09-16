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

      # default for unused subdomains
      virtualHosts."_" = mkDefault {
        default = true;
        rejectSSL = true;
        locations."/".extraConfig = ''
          return 444;
        '';
      };
    };
  };
}
