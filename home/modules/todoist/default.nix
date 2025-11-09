{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.todoist;
in {
  options.modules.todoist = {
    enable = mkEnableOption "todoist";
    electronApp.enable = mkEnableOption "todoist electron app";
    cliProgram.enable = mkEnableOption "todoist cli program";
    quickAdd = {
      enable = mkEnableOption "todoist quick add";
      impl = mkOption {
        type = types.enum ["terminal" "rofi"];
        default = "terminal";
        description = "The implementation of todoist quick add.";
      };
      rofi.configFile = mkOption {
        type = types.path;
        default = ./todoist-quick-add.rasi;
        description = "The rofi config file to use in case the rofi implementation is used.";
      };
    };
  };

  config = let
    electron = cfg.electronApp.enable;
    cli = cfg.cliProgram.enable || cfg.quickAdd.enable;
    rofi = cfg.quickAdd.impl == "rofi";
  in
    mkIf cfg.enable {
      home.packages = mkMerge [
        (mkIf electron [pkgs.todoist-electron])
        (mkIf cli [pkgs.todoist])
        (mkIf rofi [pkgs.rofi])
      ];

      sops.secrets."todoist-token" = {
        format = "json";
        sopsFile = ./secrets.json;
        key = "";
        mode = "0600";
      };

      # Todoist cli cant handle links
      home.activation.todoist-token = mkIf cli (
        config.utils.mkForceCopySecret {
          secret = "todoist-token";
          destPath = "${config.xdg.configHome}/todoist/config.json";
        }
      );
    };
}
