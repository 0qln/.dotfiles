{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.starship;
in {
  #TODO: write a dependency on fonts module
  # imports = [
  #   # Starship requires nerd fonts.
  #   ../fonts
  # ];

  options.modules.starship = {
    enable = mkEnableOption "starship";
    presets = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "presets to use (see https://starship.rs/presets/ for a list of valid options)";
    };
    settings = mkOption {
      type = types.attrs;
      default = {};
      description = "starship settings";
    };
  };

  config = mkIf cfg.enable {
    programs.starship = {
      enable = true;
      settings = lib.mkMerge ([
          cfg.settings
        ]
        ++ map (preset: (builtins.fromTOML
          (
            builtins.readFile "${pkgs.starship}/share/starship/presets/${preset}.toml"
          )))
        cfg.presets);
    };
  };
}
