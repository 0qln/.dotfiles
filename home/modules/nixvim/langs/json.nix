{pkgs, ...}: {
  home.packages = with pkgs; [
    nodePackages.jsonlint
  ];
}
