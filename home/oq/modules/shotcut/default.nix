{ pkgs, ... }:
{
  # video editing
  home.packages = with pkgs; [
    shotcut
  ];
}
