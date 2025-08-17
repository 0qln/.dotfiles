args@{ pkgs, ... }:
let
  # change this import to change the cursor
  cursorPack = utils.mkCursorPack (import ./frieren-winter.nix);
  utils = args.utils args;
in
{
  home.pointerCursor = cursorPack;
}
