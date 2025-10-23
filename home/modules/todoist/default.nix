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
    quickAdd.enable = mkEnableOption "todoist quick add";
    cliProgram.enable = mkEnableOption "todoist cli program";
  };

  config = let
    cli = cfg.cliProgram.enable || cfg.quickAdd.enable;
  in
    mkIf cfg.enable {
      home.packages = mkMerge [
        (mkIf cfg.electronApp.enable [pkgs.todoist-electron])
        (mkIf cli [pkgs.todoist])
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
