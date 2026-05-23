{pkgs, ...}: let
  profile = "(nix) odoo";
in {
  imports = [
    (import ../langs/python.nix profile)
    (import ../langs/_common.nix profile)
    (import ../appearance/themes/default profile)
    (import ../modules/odoo.nix profile)
    (import ../modules/_common.nix profile)
  ];
}
