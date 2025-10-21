{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.fonts;
in {
  options.modules.fonts = {
    enable = mkEnableOption "fonts";
    # customFonts = mkOption {
    #   type = types.enum ();
    #   description = "The fonts to install";
    # };
    # packages = mkOption {
    #   type = types.listOf types.package;
    #   description = "Font packages";
    # };
  };

  config = mkIf cfg.enable {
    fonts.fontconfig.enable = true;

    #TODO: feature gate
    home.packages = with pkgs; [
      nerd-fonts.victor-mono
      ibm-plex
    ];

    #TODO: feature gate
    home.file.".local/share/fonts/CartographCF" = {
      source = "${import ./cartograph-cf/derivation.nix {inherit pkgs;}}";
      recursive = true;
    };
  };
}
