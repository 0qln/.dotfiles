{pkgs, ...}: {
  home.packages = with pkgs; [
    fontforge
    nerd-font-patcher
  ];
}
