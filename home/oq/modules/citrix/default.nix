{ pkgs, ... }:
{
  imports = [
    ./patches.nix
  ];

  home.packages = with pkgs; [
    citrix_workspace_24_08_0
  ];
}
