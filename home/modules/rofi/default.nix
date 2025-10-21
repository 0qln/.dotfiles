{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.rofi;
in {
  options.modules.rofi = {
    enable = mkEnableOption "rofi";
    theme = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "A folder containing atleast a 'theme.rasi' file";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      rofi
    ];

    home.file = {
      ".config/rofi/config.rasi" = {
        source = config.lib.file.mkOutOfStoreSymlink ./rasi/config.rasi;
      };
      ".config/rofi/theme" = mkIf (cfg.theme != null) {
        source = config.lib.file.mkOutOfStoreSymlink cfg.theme;
        recursive = true;
      };
    };
  };
}
