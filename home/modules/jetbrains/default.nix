{
  config,
  lib,
  ...
}: let
  cfg = config.modules.jetbrains;
in
  with lib; {
    options.modules.jetbrains = {
      enable = mkEnableOption "jetbrains";
      tools = mkOption {
        type = types.listOf types.package;
        default = [];
        description = "The jetbrains packages to install";
      };
    };

    config = mkIf cfg.enable {
      home.packages = cfg.tools;
    };
  }
