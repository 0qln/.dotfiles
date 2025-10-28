{pkgs}:
pkgs.stdenvNoCC.mkDerivation {
  pname = "Cartograph CF Nerd Font";
  version = "v1.0.2";
  src = pkgs.fetchFromGitHub {
    owner = "0qln";
    repo = "Cartograph";
    rev = "bc26fabe56523f009eb9f61d99bee8e35f2e635c";
    hash = "sha256-6TAy4n5V4SuT5SuuqYvBIoJF1AJaprm4OQZB8cYs8Ls=";
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
