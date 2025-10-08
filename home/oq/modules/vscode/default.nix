{pkgs, ...}: let
  package = pkgs.vscode-fhs;
in {
  imports = [
    ./profiles/default.nix
    ./profiles/kimai.nix
    ./profiles/odoo.nix
    ./profiles/odoo.kanagawa.nix
  ];

  home.packages = with pkgs; [
    package
  ];

  programs.vscode = {
    enable = true;
    inherit package;
  };
}
