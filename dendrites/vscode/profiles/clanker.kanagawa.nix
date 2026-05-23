{pkgs, ...}: let
  profile = "(nix) clanker.kanagawa";
in {
  imports = [
    (import ../langs/_common.nix profile)
    (import ../appearance/themes/kanagawa profile)
    (import ../modules/_common.nix profile)
    (import ../modules/clanker.nix profile)
  ];
}
