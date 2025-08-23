{ pkgs, ... }:
{
  home.file."repos/work.devops/shell.nix" = {
    source = ./work.devops/shell.nix;
  };
}
