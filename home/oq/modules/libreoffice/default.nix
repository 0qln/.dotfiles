{pkgs, ...}: {
  imports = [
    ./spellcheck.nix
  ];

  home.packages = with pkgs; [
    libreoffice-qt
  ];
}
