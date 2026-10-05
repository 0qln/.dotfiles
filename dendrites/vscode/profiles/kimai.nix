{pkgs, ...}: let
  profile = "(nix) kimai";
in {
  imports = [
    (import ../langs/php.nix profile)
    (import ../langs/php.remote.nix profile)
    (import ../langs/_common.nix profile)
    (import ../appearance/themes/default profile)
    (import ../modules/kimai.nix profile)
    (import ../modules/_common.nix profile)
  ];
}
