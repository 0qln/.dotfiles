{pkgs, ...}: let
  fonts = with pkgs;
    [
      nerd-fonts.victor-mono
      ibm-plex
    ]
    ++ [
      # (import ./cartograph-cf/derivation.nix { inherit pkgs; })
    ];
in {
  home.packages = fonts;
  fonts.fontconfig.enable = true;

  imports = [
    ./cartograph-cf/default.nix
    ./tools.nix
  ];
}
