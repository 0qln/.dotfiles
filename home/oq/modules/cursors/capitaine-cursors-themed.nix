{reload-service}: {pkgs, ...}: let
  size = 24;
  name = "Capitaine Cursors";
  # name = "Capitaine Cursors (Nord)";
in {
  home.file.".icons/default" = {
    source = "${pkgs.capitaine-cursors-themed}/share/icons/${name}";
  };

  systemd.user.services."reload-cursor" = reload-service name size;
}
