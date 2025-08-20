{ reload-service }:
args@{ pkgs, ... }:
let
  utils = args.utils args;
  name = "Frieren Winter Cursor";
  size = 24;
  cursorPack = utils.mkCursorPackWin {
    url = "https://github.com/ctrlcat0x/cursors/raw/73adfb71f60d04283d48aad0771769bcc211612d/cursor_pack_1/frieren_winter.zip";
    hash = "sha256-i4fN/35ozQaosZMuZadb2LMKoY1Fm8u8ZZPocptaqa8=";
    inherit name;
    inherit size;
  };
in
{
  home.pointerCursor = cursorPack;

  systemd.user.services."reload-cursor" = reload-service name size;
}
