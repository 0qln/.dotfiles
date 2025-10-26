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
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      starship
    ];
  };
}
