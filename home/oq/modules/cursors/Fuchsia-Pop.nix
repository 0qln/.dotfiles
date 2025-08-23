{ reload-service }:
args@{ pkgs, ... }:
let
  utils = args.utils args;
  name = "Fuchsia-Pop";
  size = 24;
  cursorPack = utils.mkCursorPack {
    url = "https://github.com/ful1e5/fuchsia-cursor/releases/download/v2.0.0/Fuchsia-Pop.tar.gz";
    hash = "sha256-BvVE9qupMjw7JRqFUj1J0a4ys6kc9fOLBPx2bGaapTk=";
    inherit name;
  };
in
{
  home.pointerCursor = cursorPack;

  systemd.user.services."reload-cursor" = reload-service name size;
}
