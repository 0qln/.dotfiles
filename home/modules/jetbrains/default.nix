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

    # docs
    # https://nixos.wiki/wiki/Jetbrains_Tools
    # https://discourse.nixos.org/t/latest-intellij-idea-ultimate/43103/9

    config = mkIf cfg.enable {
      home.packages = cfg.tools;
    };
  }
