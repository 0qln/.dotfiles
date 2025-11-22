{pkgs, ...}: {
  home.packages = with pkgs; [
    xmlstarlet
  ];
}
