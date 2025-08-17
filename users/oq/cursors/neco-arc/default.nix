{ reload-service }:
args@{ pkgs, ... }:
let
  utils = args.utils args;
  name = "Neco Arc";
  size = 24;
  #TODO: mappings from the win states to linux states
  # - https://www.reddit.com/r/linuxquestions/comments/mkvdel/comment/khaxcvt/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
  # - https://www.opendesktop.org/p/999853
  # - https://archive.ph/5NRMb
  cursorPack = utils.mkCursorPackWin {
    url = "https://www.rw-designer.com/cursor-downloadset.php?id=neco-arc";
    hash = "sha256-MgEvVB9kWowqfuXC3UJtOFLTpWbWfdSnvNOXdZwqYxM=";
    inherit name;
    inherit size;
  };
in
{
  home.pointerCursor = cursorPack;

  systemd.user.services."reload-cursor" = reload-service name size;
}
