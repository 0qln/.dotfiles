{ pkgs, host-name, ... }:
let
  monitors = import ../../../hosts/${host-name}/monitors.nix { };
in
{
  # docs:
  # https://home-manager-options.extranix.com/?query=linux-wallpaperengine&release=release-25.05
  # https://mynixos.com/home-manager/options/services.linux-wallpaperengine
  # https://github.com/Almamu/linux-wallpaperengine

  # in case i am also as lost as this dud:
  # https://discourse.nixos.org/t/how-is-linux-wallpaperengine-supposed-to-work-on-nixos/37126/6

  services.linux-wallpaperengine = {
    enable = true;
    wallpapers = [
      {
        monitor = monitors.center;
        wallpaperId = "3549235003";
      }
    ];
  };
}
