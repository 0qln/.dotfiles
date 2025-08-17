{ reload-service }:
args@{ pkgs, ... }:
let
  utils = args.utils args;
  name = "Sweet-Dark";
  size = 24;
  cursorPack = utils.mkCursorPack {
    url = "https://github.com/EliverLara/Sweet/releases/download/v6.0/Sweet-Dark.tar.xz";
    hash = "sha256-BvVE9qupMjw7JRqFUj1J0a4ys6kc9fOLBPx2bGaapTk=";
    inherit name;
  };
in
{
  home.pointerCursor = cursorPack;

  systemd.user.services."reload-cursor" = reload-service name size;
}
