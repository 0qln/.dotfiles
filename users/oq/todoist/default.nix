{ pkgs, config, ... }:
let
in
{
  home.packages = with pkgs; [
    todoist-electron
    todoist
  ];
}
