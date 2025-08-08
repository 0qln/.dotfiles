{ pkgs, ... }:
{
  home.packages = with pkgs; [
    rofi-wayland
  ];

  home.file.".config/rofi" = {
    source = ../rofi;
    recursive = true;
  };
  home.file.".config/rofi/rofi-themes-collection" = {
    source = ../rofi/rofi-themes-collection;
    recursive = true;
  };
}
