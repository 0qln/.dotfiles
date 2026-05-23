{inputs, ...}:
with inputs.nixpkgs.lib; {
  flake.nixosModules.distrobox = {
    config,
    pkgs,
    ...
  }: let
    cfg = config.modules.distrobox;
  in {
    options.modules.distrobox = {
      enable = mkEnableOption "distrobox system dependencies";
    };

    config = mkIf cfg.enable {
      virtualisation.podman = {
        enable = true;
        dockerCompat = !config.modules.docker.enable;
      };

      environment.systemPackages = [
        pkgs.distrobox
      ];
    };
  };
}
