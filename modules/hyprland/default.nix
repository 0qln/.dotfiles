{ config, pkgs, ... }:
let
in {
  environment.systemPackages = with pkgs; [
    hyprland
    kitty # required for the default Hyprland config
    playerctl
    brightnessctl
    wl-clipboard-rs
  ];
  programs.hyprland.enable = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
