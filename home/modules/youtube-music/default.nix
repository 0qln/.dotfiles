{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.ytm;
in {
  options.modules.ytm = {
    enable = mkEnableOption "youtube music";
    stylesheet = mkOption {
      type = types.nullOr types.lines;
      default = null;
      description = "The css stylesheet";
    };
    stylesheetFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "A path to the css stylesheet";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      pear-desktop # youtube-music
    ];

    #TODO: there is an extension for transparency now. see if that works.
    # nixpkgs.overlays = [
    #   (
    #     final: prev:
    #       prev.pear-desktop.override {
    #         patches = [./transparency.patch];
    #       }
    #   )
    # ];

    home.file.".config/ytm/stylesheet.css" = {
      text = mkIf (cfg.stylesheet != null) cfg.stylesheet;
      source = mkIf (cfg.stylesheetFile != null) cfg.stylesheetFile;
    };
  };
}
