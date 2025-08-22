{ pkgs, ... }:
{
  home.file.".local/share/fonts/CartographCF" = {
    source = ./CartographCF;
    recursive = true;
  };
}
