{inputs, ...}:
with inputs.nixpkgs.lib; {
  flake.nixosModules.fonts = {
    inputs,
    config,
    ...
  }: let
    cfg = config.modules.fonts;
  in {
    options.modules.fonts = {
      enable = mkEnableOption "fonts";
    };
    config = mkIf cfg.enable {
      nixpkgs = {
        overlays = [
          inputs.nur.overlays.default

          # todo:
          # why were these needed here?
          # shouldn't it be enough to import them in the home manager config?
          # if needed, move into the dendrite
          #
          # inputs.cartograph-cf.overlays.default
          # inputs.angel-wish.overlays.default
          # inputs.ruritania.overlays.default
          # inputs.kingjola.overlays.default
        ];
      };
    };
  };

  flake.homeModules.fonts = {
    pkgs,
    config,
    inputs,
    ...
  }: let
    cfg = config.modules.fonts;
  in {
    options.modules.fonts = {
      enable = mkEnableOption "fonts";
      cartograph-cf.enable = mkEnableOption "cartograph-cf (nerd-font)";
      angel-wish.enable = mkEnableOption "angel wish";
      ruritania.enable = mkEnableOption "ruritania";
      kingjola.enable = mkEnableOption "kingjola";
      old-london.enable = mkEnableOption "old-london";
      ibm-plex.enable = mkEnableOption "ibm-plex";
      victor-mono.enable = mkEnableOption "victor-mono (nerd-font)";
      jetbrains-mono.enable = mkEnableOption "jetbrains-mono (nerd-font)";
    };

    config = mkIf cfg.enable {
      nixpkgs.overlays = [
        inputs.cartograph-cf.overlays.default
        inputs.angel-wish.overlays.default
        inputs.ruritania.overlays.default
        inputs.kingjola.overlays.default
        inputs.old-london.overlays.default
      ];

      fonts.fontconfig.enable = true;

      home.packages = with pkgs;
        (optionals cfg.victor-mono.enable [nerd-fonts.victor-mono])
        ++ (optionals cfg.jetbrains-mono.enable [nerd-fonts.jetbrains-mono])
        ++ (optionals cfg.ibm-plex.enable [ibm-plex])
        ++ (optionals cfg.angel-wish.enable [angel-wish])
        ++ (optionals cfg.cartograph-cf.enable [cartographcf-nerdfont])
        ++ (optionals cfg.ruritania.enable [ruritania])
        ++ (optionals cfg.kingjola.enable [kingjola])
        ++ (optionals cfg.old-london.enable [old-london]);
    };
  };
}
