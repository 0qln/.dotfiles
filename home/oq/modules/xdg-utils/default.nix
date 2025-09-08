{pkgs, ...}: {
  home.packages = with pkgs; [
    xdg-utils
  ];

  imports = [
    ./xdg-mime.nix
  ];
}
