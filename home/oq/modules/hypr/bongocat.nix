{
  inputs,
  lib,
  ...
}: let
  vars = import ./variables.nix;
  pawRatio = 1.0 / 3.1;
  catRatio = 1.0 - pawRatio;
  catHeight = totalHeight * catRatio;
  pawHeight = vars.margin_out;
  totalHeight = pawHeight / pawRatio;
in {
  imports = [
    inputs.bongocat.homeModule.default
  ];

  programs.wayland-bongocat = {
    enable = true;
    autostart = true;
    inputDevices = map (i: "/dev/input/event${toString i}") (lib.lists.range 0 8);
    enableAntialiasing = true;
    overlayOpacity = 0;
    overlayHeight = builtins.floor totalHeight;
    overlayPosition = "bottom";
    catHeight = builtins.floor catHeight;
    catAlign = "right";
    catXOffset = 10 + vars.margin_out;
    catYOffset = 0;
  };
}
