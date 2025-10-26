{pkgs, ...}: {
  home.packages = with pkgs; [
    pylint
    pyright
  ];
}
