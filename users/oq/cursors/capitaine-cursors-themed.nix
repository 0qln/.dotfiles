{ reload-service }:
{ pkgs, ... }:
let
  size = 24;
  name = "Capitaine Cursors";
  # name = "Capitaine Cursors (Nord)";
in
{
  home.file.".icons/default" = {
    source = "${pkgs.capitaine-cursors-themed}/share/icons/${name}";
  };

  # wayland.windowManager.hyprland.settings = {
  #   env = [
  #     "HYPRCURSOR_THEME,${name}"
  #     "HYPRCURSOR_SIZE,${size}"
  #   ];
  # };

  systemd.user.services."reload-cursor" = reload-service name size;
}
