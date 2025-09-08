{pkgs, ...}: let
  profile = "Worksimple.KimaiEfecteSyncPlugin | apoth_everforest";
in {
  imports = [
    (import ../langs/php.remote.nix profile)
    (import ../langs/_common.nix profile)
    (import ../appearance/profiles/apoth_everforest/default.nix profile)
    (import ../modules/_common.nix profile)
  ];
}
