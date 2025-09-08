{reload-service}: args @ {pkgs, ...}: let
  utils = args.utils args;
  name = "Hatsune-Miku";
  size = 48;
  cursorPack = utils.mkCursorPackLocal {
    url = "https://store.kde.org/p/2303818";
    fileName = "Hatsune-Miku.tar.gz";
    archiveHash = "0ql1cn8zk3hgsz7zywxv3f1larhk175937y06am0yywnhiqfg98l";
    packName = name;
    packHash = "sha256-60iy/mE5n3tAcUwLyN5UZkNdA565IO3YD6H8mc3pROA=";
    inherit size;
  };
in {
  home.pointerCursor = cursorPack;

  systemd.user.services."reload-cursor" = reload-service name size;
}
