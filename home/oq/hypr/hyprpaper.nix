{ pkgs, ... }:
let
  wallhaven-zygxxo = toString ../wallpapers/wallhaven-zygxxo.jpg;
  wallhaven-6o1lrl = toString (pkgs.fetchurl {
    url = "https://w.wallhaven.cc/full/6o/wallhaven-6o1lrl.jpg";
    hash = "sha256-ZJ1fa+0zVaIkVm+TJdpo58FW5UHqGliehSoqPuV8bD8=";
  });
  wallhaven-5gx2q5 = toString (pkgs.fetchurl {
    url = "https://w.wallhaven.cc/full/5g/wallhaven-5gx2q5.png";
    hash = "sha256-2gpyEJ9GkTCnVMYbreKXB6QJTVvKc2Up8LHoPCHJ9Os=";
  });
in {
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      preload = [
        wallhaven-zygxxo
        wallhaven-6o1lrl
        wallhaven-5gx2q5
      ];
      wallpaper = [
        # "HDMI-A-1, ${wallpaper1}"
        ",${wallhaven-5gx2q5}"
      ];
    };
  };
}
