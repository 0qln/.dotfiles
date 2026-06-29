{
  inputs,
  self,
  ...
}:
with inputs.nixpkgs.lib; {
  imports = [
    ./opts.nix
  ];

  flake.nixosModules.distrobox = {
    config,
    pkgs,
    ...
  }: let
    cfg = config.modules.distrobox;
  in {
    imports = [
      self.nixosModules.xdg
    ];

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

      # flatpak needs xdg
      {
        modules.xdg.enable = true;
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

  flake.homeModules.distrobox = {config, ...}: let
    cfg = config.modules.distrobox;
  in {
    imports = [
      self.homeModules.xdg
    ];

    config = mkIf cfg.enable {
      # flatpak needs xdg
      modules.xdg.enable = true;
    };
  };
}
