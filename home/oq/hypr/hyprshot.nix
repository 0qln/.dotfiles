{ pkgs, ... }:
{
  home.packages = with pkgs; [
    hyprshot
  ];

  wayland.windowManager.hyprland.settings.bind = [
    ", PRINT, exec, hyprshot -m output"
    "SUPER, PRINT, exec, hyprshot -m window"
    "SHIFT SUPER, PRINT, exec, hyprshot -m region"
  ];
}
