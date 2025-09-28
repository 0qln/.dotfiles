{pkgs, ...}: {
  home.packages = with pkgs; [
    hyprshot
  ];

  wayland.windowManager.hyprland.settings.bind = [
    ", PRINT, exec, hyprshot -z -m output"
    "SUPER, PRINT, exec, hyprshot -z -m window"
    "SHIFT SUPER, PRINT, exec, hyprshot -z -m region"
  ];
}
