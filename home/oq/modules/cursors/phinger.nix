{reload-service}: {pkgs, ...}: let
  size = 24;
  name = "phinger-cursors-dark";
in {
  home.file.".icons/default" = {
    source = "${pkgs.phinger-cursors}/share/icons/${name}";
  };

  systemd.user.services."reload-cursor" = reload-service name size;
}
