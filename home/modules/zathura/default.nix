{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.zathura;
in {
  options.modules.zathura = {
    enable = mkEnableOption "zathura";
    zathurarc = mkOption {
      type = types.nullOr types.lines;
      default = null;
      description = "The zathurarc";
    };
    zathurarcFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "A path to the zathurarc";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      zathura
    ];

    home.file.".config/zathura/zathurarc" = {
      text = mkIf (cfg.zathurarc != null) cfg.zathurarc;
      source = mkIf (cfg.zathurarcFile != null) cfg.zathurarcFile;
    };
  };
}
