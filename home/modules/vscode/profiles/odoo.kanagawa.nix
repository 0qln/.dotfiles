{pkgs, ...}: let
  profile = "odoo.kanagawa";
in {
  imports = [
    (import ../langs/python.nix profile)
    (import ../langs/_common.nix profile)
    (import ../appearance/profiles/kanagawa profile)
    (import ../modules/odoo.nix profile)
    (import ../modules/_common.nix profile)
  ];
}
