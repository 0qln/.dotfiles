{ pkgs, ... }:
{
  home.packages = with pkgs; [
    oneko
  ];
}
