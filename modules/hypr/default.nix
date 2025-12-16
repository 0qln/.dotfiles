{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.modules.hypr;
in {
  options.modules.hypr = {
    enable = mkEnableOption "hypr.* stuff";
  };

  config = mkIf cfg.enable {
    modules.nix.caches = {"hyprland.cachix.org" = "a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=";};

    # You can disable this if you're only using the Wayland session.
    services.xserver.enable = false; # Enable the X11 windowing system.

    services.displayManager.sddm.wayland.enable = true;
    services.displayManager.sddm.enable = true;

    environment.systemPackages = with pkgs; [
      kitty # required for the default Hyprland config
      playerctl
      brightnessctl
      wl-clipboard-rs
      inputs.hyprpaper.packages.${pkgs.system}.hyprpaper
      mako
      libnotify
    ];
    programs.hyprland = {
      enable = true;
      # set the flake package
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      # make sure to also set the portal package, so that they are in sync
      portalPackage =
        inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    };
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

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };

    # Enable touchpad support (enabled default in most desktopManager).
    # services.xserver.libinput.enable = true;

    services.pipewire.wireplumber = {
      enable = true;
    };

    # needed for hyprlock
    # (https://home-manager-options.extranix.com/?query=programs.hyprlock.enable&release=release-25.11)
    security.pam.services.hyprlock = {};
  };
}
