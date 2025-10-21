{pkgs, ...}: {
  home.packages = with pkgs; [
    wallust
  ];
}
