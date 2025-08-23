{ reload-service }:
args@{ pkgs, ... }:
let
  utils = args.utils args;
  name = "Maomao Cursor";
  size = 24;
  #TODO
  cursorPack = utils.mkCursorPackWin {
    url = "https://www.rw-designer.com/cursor-downloadset.php?id=maomao";
    hash = "sha256-+k46DPVfypKego7YWH+txUmom5VCvYBCkRQOzbgKb4c=";
    inherit name;
    inherit size;
  };
in
{
  home.pointerCursor = cursorPack;

  systemd.user.services."reload-cursor" = reload-service name size;
}
