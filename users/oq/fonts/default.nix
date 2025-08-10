{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nerd-fonts.victor-mono
  ];
}
