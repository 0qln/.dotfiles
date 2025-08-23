{ pkgs, ... }:
{
  imports = [
    ./frosted-glass.theme.nix
    ./dark-matter.theme.nix
    ./system24.theme.nix
  ];

  home.packages = with pkgs; [
    vesktop
  ];
}
