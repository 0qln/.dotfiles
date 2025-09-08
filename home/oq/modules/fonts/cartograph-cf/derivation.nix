{pkgs}:
pkgs.stdenvNoCC.mkDerivation {
  pname = "Cartograph CF Nerd Font";
  version = "v1.0.0";
  src = pkgs.fetchFromGitHub {
    owner = "g5becks";
    repo = "Cartograph";
    rev = "eecba04db96206933496a8b845f68c19decb3c64";
    hash = "sha256-P8cii7ez9bAE+c7tN+oWQy3/LQPFtGUmlwQsKevbl0M=";
  };
  buildInputs = with pkgs; [
    fontforge
    nerd-font-patcher
  ];

  buildPhase = ''
    mkdir -p patched-fonts
    for font in *.otf; do
      ${pkgs.nerd-font-patcher}/bin/nerd-font-patcher \
        --complete \
        --outputdir patched-fonts \
        "$font"
    done
  '';

  installPhase = ''
    mkdir -p "$out/share/fonts/opentype"
    cp patched-fonts/*.otf "$out/share/fonts/opentype/"
  '';
}
