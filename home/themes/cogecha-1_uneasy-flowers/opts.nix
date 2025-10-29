{lib, ...}:
with lib; let
  name = import ./name.nix;
in {
  options.themes.${name} = {
    enable = mkEnableOption name;
  };
}
