{inputs, ...}: {
  flake.nixosModules.theme_idekanymore = {
    lib,
    config,
    ...
  }:
    with lib; let
      cfg = config.modules.themes.idekanymore;
    in {
      options.modules.themes.idekanymore = {
        enable = mkEnableOption "[Theme] idekanymore";
      };

      config = mkIf cfg.enable {
        # wallpaperengine
        modules.steam.enable = true;
      };
    };

  flake.homeModules.theme_idekanymore = {...}: {
    # todo
  };
}
