{pkgs, ...}: let
  profile = "(nix) default";
in {
  imports = [
    (import ../langs/_all.nix profile)
    (import ../appearance/themes/default/default.nix profile)
    (import ../modules/_common.nix profile)
  ];
}
