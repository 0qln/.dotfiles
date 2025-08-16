{ pkgs, ... }:
let
  fonts = with pkgs; [
    nerd-fonts.victor-mono
    ibm-plex
  ];
in
{
  home.packages = fonts;
  fonts.fontconfig.enable = true;
}
