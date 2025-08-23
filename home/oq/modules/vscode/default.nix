{ pkgs, ... }:
let
  package = pkgs.vscode-fhs;
in
{
  imports = [
    ./profiles/default.nix
    ./profiles/Worksimple.KimaiEfecteSyncPlugin.nix
  ];

  home.packages = with pkgs; [
    package
  ];

  programs.vscode = {
    enable = true;
    inherit package;
  };
}
