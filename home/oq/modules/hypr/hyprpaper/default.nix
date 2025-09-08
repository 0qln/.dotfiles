{pkgs, ...}: {
  imports = [
    ./wlop-1_chinese-festival.nix
  ];

  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
    };
  };
}
