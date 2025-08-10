{ pkgs, ... }:
{
  imports = [
    # Starship requires nerd fonts.
    ../fonts
  ];

  home.packages = with pkgs; [
    starship
  ];
}
