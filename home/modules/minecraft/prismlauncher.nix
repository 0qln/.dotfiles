{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.minecraft.prismlauncher;
in
  with lib; {
    options.modules.minecraft.prismlauncher = {
      enable = mkEnableOption "prismlauncher";
    };

    config = mkIf cfg.enable {
      home.packages = with pkgs; [
        prismlauncher
      ];
    };
  }
