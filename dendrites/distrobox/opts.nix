{inputs, ...}:
with inputs.nixpkgs.lib; {
  flake.nixosModules.distrobox-opts = {...}: {
    options.modules.distrobox = {
      enable = mkEnableOption "distrobox system dependencies";
    };
  };

  flake.homeModules.distrobox-opts = {...}: {
    options.modules.distrobox = {
      enable = mkEnableOption "distrobox system dependencies";
    };
  };
}
