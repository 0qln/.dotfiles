{ config, pkgs, ... }:
let
in {
  environment.systemPackages = with pkgs; [
    hyprland
    kitty # required for the default Hyprland config
    playerctl
    brightnessctl
    wl-clipboard-rs
    mako
    pipewire

  ];
  programs.hyprland.enable = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # rtkit (optional, recommended) allows Pipewire to use the realtime scheduler for increased performance.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true; # if not already enabled
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment the following
    #jack.enable = true;
  };

  services.pipewire.wireplumber.enable = true;
}
