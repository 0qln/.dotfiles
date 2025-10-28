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
    cartograph-cf.enable = mkEnableOption "cartograph-cf (nerd-font)";
    ibm-plex.enable = mkEnableOption "ibm-plex";
    victor-mono.enable = mkEnableOption "victor-mono (nerd-font)";
  };

  config = mkIf cfg.enable {
    fonts.fontconfig.enable = true;

    home.packages = with pkgs;
      (optionals cfg.victor-mono.enable [nerd-fonts.victor-mono])
      ++ (optionals cfg.ibm-plex.enable [ibm-plex]);

    home.file.".local/share/fonts/CartographCF" = mkIf cfg.cartograph-cf.enable {
      source = "${import ./cartograph-cf/derivation.nix {inherit pkgs;}}";
      recursive = true;
    };
  };
}
