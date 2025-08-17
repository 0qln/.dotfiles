{ reload-service }:
{ pkgs, ... }:
let
  size = 24;
  name = "DMZ (White)";
in
{
  home.file.".icons/default".source = "${pkgs.vanilla-dmz}/share/icons/Vanilla-DMZ";

  # wayland.windowManager.hyprland.settings = {
  #   env = [
  #     "HYPRCURSOR_THEME,${name}"
  #     "HYPRCURSOR_SIZE,${toString size}"
  #   ];
  # };

  systemd.user.services."reload-cursor" = reload-service name size;
}
