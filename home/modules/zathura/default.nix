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
    setDefault = mkOption {
      type = types.listOf types.str;
      default = [];
      example = ["application/pdf"];
      description = "Set as default app for these";
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

    xdg.mimeApps.defaultApplications = builtins.listToAttrs (
      map (type: {
        name = type;
        value = "org.pwmt.zathura-pdf-mupdf.desktop";
      })
      cfg.setDefault
    );
  };
}
