{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.obsidian;
in {
  options.modules.obsidian = {
    enable = mkEnableOption "obsidian";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      obsidian
    ];
  };
}
