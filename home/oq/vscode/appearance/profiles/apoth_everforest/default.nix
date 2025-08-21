profile:
{ ... }:
{
  imports = [
    (import ../../modules/misc.nix profile)
    (import ../../modules/editor.nix profile)
    # (import ../../icons/eq-material-theme-icons.nix profile) #TODO: replace with the non-depricated alternative
    (import ./background.nix profile)
    (import ./colors.nix profile)
    (import ./editor.nix profile)
  ];
}
