{ reload-service }:
args@{ pkgs, ... }:
let
  utils = args.utils args;
  name = "Sweet-Dark";
  size = 24;
  cursorPack = utils.mkCursorPackLocal {
    url = "https://store.kde.org/p/1393084";
    fileName = "Sweet-cursors.tar.xz";
    archiveHash = "131wk1r671idqf9m1k5166mjk0yx7l1kxd4v4nymfl0c6b7i7a4k";
    packName = name;
    packHash = "sha256-RPGnszDsQRKtmHK16Daw1Awuqa4uSTqtoxK4mqyzM8A=";
    inherit size;
  };
in
{
  home.pointerCursor = cursorPack;

  systemd.user.services."reload-cursor" = reload-service name size;
}
