{pkgs, ...}: let
  profile = "default";
in {
  imports = [
    (import ../langs/_all.nix profile)
    (import ../appearance/profiles/default/default.nix profile)
    (import ../modules/_common.nix profile)
  ];
}
