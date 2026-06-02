{inputs, ...}:
with inputs.nixpkgs.lib; {
  flake.nixosModules.xdg-opts = {...}: {
    options.modules.xdg = {
      enable = mkEnableOption "xdg stuff";
    };
  };

  flake.homeModules.xdg-opts = {...}: {
    options.modules.xdg = {
      enable = mkEnableOption "xdg stuff";
    };
  };
}
