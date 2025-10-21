{lib, ...}:
with lib; {
  options = {
    modules.hypr = {
      enable = mkEnableOption "hypr";
    };
  };
  imports = [
    ./hyprpicker.nix
    ./hyprland
    ./hyprpaper
    ./hyprshot.nix
    ./waybar.nix
    ./wlsunset.nix
    ./bongocat.nix
  ];
}
