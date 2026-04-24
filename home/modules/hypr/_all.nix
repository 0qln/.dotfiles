{flake, ...}: {
  imports = [
    ./hyprpicker.nix
    ./hyprland
    ./hyprpaper
    ./hyprshot.nix
    ./waybar
    ./wayneko.nix
    ./wlsunset.nix
    ./bongocat.nix

    flake.homeModules.hyprlock
  ];
}
