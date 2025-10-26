{
  pkgs-citrix,
  config,
  lib,
  ...
}: let
  cfg = config.modules.citrix;
in
  with lib; {
    options.modules.citrix = {
      enable = mkEnableOption "citrix";
    };

    config = mkIf cfg.enable {
      home.packages = with pkgs-citrix; [
        citrix_workspace_24_08_0
      ];
    };
  }
