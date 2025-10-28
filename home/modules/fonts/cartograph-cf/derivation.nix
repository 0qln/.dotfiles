{pkgs}:
pkgs.stdenvNoCC.mkDerivation {
  pname = "Cartograph CF Nerd Font";
  version = "v1.0.3";
  src = pkgs.fetchFromGitHub {
    owner = "0qln";
    repo = "Cartograph";
    rev = "3a23f288eee24a36005ec30fd9778a5d6a854510";
    hash = "sha256-wk4SckewRtmVdT7VCeEndpIBwrWqQLn6mp2DZcqMnIE=";
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
