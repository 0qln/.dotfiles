{ pkgs }:
pkgs.stdenvNoCC.mkDerivation {
  pname = "CartographCF";
  version = "v1.0.0";
  src = pkgs.fetchFromGitHub {
    owner = "g5becks";
    repo = "Cartograph";
    rev = "eecba04db96206933496a8b845f68c19decb3c64";
    hash = "";
  };

}

# this is not the right way to install custom fonts...
# see: https://nixos.wiki/wiki/Fonts
