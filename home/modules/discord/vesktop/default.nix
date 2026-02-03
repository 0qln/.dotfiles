{
  pkgs-hot,
  config,
  lib,
  ...
}: let
  cfg = config.modules.discord.vesktop;
  pkgs = pkgs-hot;
in
  with lib; {
    options.modules.discord.vesktop = {
      enable = mkEnableOption "vesktop dicord client";
      theme = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "The theme";
      };
      settings = mkOption {
        type = types.attrs;
        default = {};
        description = "Attribute set of settings that will be merged with the default vesktop settings file.";
      };
    };

    config = mkIf cfg.enable {
      home = {
        packages = with pkgs; [
          vesktop
        ];

        file.".config/vesktop/themes/${cfg.theme}.css" = {
          source = import ./themes/${cfg.theme}.theme.nix pkgs;
        };

        file.".config/vesktop/settings/settings.json" = let
          settings =
            (builtins.fromJSON (builtins.readFile ./settings.json))
            // {enabledThemes = ["${cfg.theme}.css" "${cfg.theme}.theme.css"];}
            // cfg.settings;
        in {
          source = pkgs.writeTextFile {
            name = "vesktop-settings.json";
            text = builtins.toJSON settings;
          };
        };
      };
    };
  }
