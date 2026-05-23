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

    config = mkIf cfg.enable (mkMerge [
      {
        virtualisation.podman = {
          enable = true;
          dockerCompat = !config.modules.docker.enable;
        };

        environment.systemPackages = [
          pkgs.distrobox
        ];
      }
      # need this because: https://github.com/89luca89/distrobox/issues/1198
      {
        services.flatpak.enable = true;
        environment.systemPackages = with pkgs; [
          flatpak-xdg-utils
          libportal
          xdg-dbus-proxy
          host-spawn
        ];
      }
    ]);
  };
}
