{ pkgs, ... }:
let
  monitors = import ../../../hosts/pc1/monitors.nix { };
in
{
  programs.waybar = {
    enable = true;
    style = ./waybar.css;
    settings = [
      {
        name = "barRight";
        layer = "top";
        position = "top";
        height = 30;
        output = [
          monitors.right
        ];
        modules-left = [
        ];
        modules-center = [
        ];
        modules-right = [
          "clock"
        ];
      }
      {
        name = "barLeft";
        layer = "top";
        position = "top";
        height = 30;
        output = [
          monitors.left
        ];
        modules-left = [
        ];
        modules-center = [
        ];
        modules-right = [
        ];
      }
    ];
  };
}
