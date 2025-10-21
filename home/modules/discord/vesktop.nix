{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.discord.vesktop;
in
  with lib; {
    options.modules.discord.vesktop = {
      enable = mkEnableOption "vesktop dicord client";
      theme = mkOption {
        type = types.str;
        default = "";
        description = "The theme";
      };
    };

    config = mkIf cfg.enable {
      home.packages = with pkgs; [
        vesktop
      ];
      home.file.".config/vesktop/themes/${cfg.theme}.css" = {
        source = import ./themes/${cfg.theme}.theme.nix pkgs;
      };
    };
  }
