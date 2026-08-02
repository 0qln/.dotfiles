{...}: {
  flake.homeModules.fonts = {
    pkgs,
    config,
    lib,
    inputs,
    ...
  }:
    with lib; let
      cfg = config.modules.fonts;
    in {
      options.modules.fonts = {
        enable = mkEnableOption "fonts";
        cartograph-cf.enable = mkEnableOption "cartograph-cf (nerd-font)";
        angel-wish.enable = mkEnableOption "angel wish";
        ruritania.enable = mkEnableOption "ruritania";
        ibm-plex.enable = mkEnableOption "ibm-plex";
        victor-mono.enable = mkEnableOption "victor-mono (nerd-font)";
        jetbrains-mono.enable = mkEnableOption "jetbrains-mono (nerd-font)";
      };

      config = mkIf cfg.enable {
        nixpkgs.overlays = [
          inputs.cartograph-cf.overlays.default
          inputs.angel-wish.overlays.default
          inputs.ruritania.overlays.default
        ];

        fonts.fontconfig.enable = true;

        home.packages = with pkgs;
          (optionals cfg.victor-mono.enable [nerd-fonts.victor-mono])
          ++ (optionals cfg.jetbrains-mono.enable [nerd-fonts.jetbrains-mono])
          ++ (optionals cfg.ibm-plex.enable [ibm-plex]);

        home.file.".local/share/fonts/IbmPlex" = mkIf cfg.ibm-plex.enable {
          source = "${pkgs.ibm-plex}/share/fonts/opentype";
          recursive = true;
        };

        home.file.".local/share/fonts/CartographCF" = mkIf cfg.cartograph-cf.enable {
          source = "${pkgs.cartographcf-nerdfont}/share/fonts/opentype";
          recursive = true;
        };

        home.file.".local/share/fonts/Angel wish" = mkIf cfg.angel-wish.enable {
          source = "${pkgs.angel-wish}/share/fonts/opentype";
          recursive = true;
        };

        home.file.".local/share/fonts/Ruritania" = mkIf cfg.ruritania.enable {
          source = "${pkgs.ruritania}/share/fonts/opentype";
          recursive = true;
        };
      };
    };
}
