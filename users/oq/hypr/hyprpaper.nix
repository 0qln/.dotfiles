{ inputs, pkgs, home, ... }: 
let
  wallpaper1 = toString ../wallpapers/wallhaven-zygxxo.jpg;
in {
  #   hyprpaper
  # ];
  # home.packages = with pkgs; [
  #   hyprpaper
  # ];

  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      preload = [
        wallpaper1
      ];
      wallpaper = [
        # "HDMI-A-1, ${wallpaper1}"
        ",${wallpaper1}"
      ];
    };
  };
}
