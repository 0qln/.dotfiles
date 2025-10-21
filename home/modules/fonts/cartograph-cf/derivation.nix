{pkgs}:
pkgs.stdenvNoCC.mkDerivation {
  pname = "Cartograph CF Nerd Font";
  version = "v1.0.1";
  src = pkgs.fetchFromGitHub {
    owner = "g5becks";
    repo = "Cartograph";
    rev = "eecba04db96206933496a8b845f68c19decb3c64";
    hash = "sha256-P8cii7ez9bAE+c7tN+oWQy3/LQPFtGUmlwQsKevbl0M=";
  };

  # finding the ligature tables:
  # 1. goto: https://fontdrop.info/#/?darkmode=true
  # 2. under Ligatures section you can search for the subtable lookup
  #    which contains your ligature
  # 3. under Data section you can search for your <liga> (or whatever that you found)
  #    and then the 'features' section you should be able to find something like:
  # ```json
  # {"tag":"liga","feature":{"featureParams":0,"lookupListIndexes":[14]}}
  # ```
  # 4. then you add this to the [Subtables] seciton in the config.cfg below.
  #
  # additional ressources in order of relevance:
  # - https://github.com/ryanoasis/nerd-fonts/blob/master/readme.md#font-patcher
  # - https://github.com/ryanoasis/nerd-fonts/wiki/ScriptOptions
  # - https://github.com/ryanoasis/nerd-fonts/discussions/1514
  # - https://github.com/ryanoasis/nerd-fonts/blob/master/src/config.sample.cfg
  # - https://github.com/ORutherford/nerd-fonts/blob/9e38cef075f016301e10f9097590b3fb005fb47e/src/unpatched-fonts/Noto/Sans/config.json
  # - https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/FiraCode#ligatures
  #
  # TODO: find a way to only remove the '.=' ligature, the other ones are fine.
  #
  patchPhase = ''
    cat > config.cfg <<EOF
    [Subtables]
    ligatures: [
            "'liga' Standard Ligatures lookup 14 subtable" ]
    EOF
  '';

  buildInputs = with pkgs; [
    fontforge
    nerd-font-patcher
  ];

  buildPhase = ''
    mkdir -p patched-fonts
    for font in *.otf; do
      ${pkgs.nerd-font-patcher}/bin/nerd-font-patcher \
        --complete \
        --configfile config.cfg \
        --removeligatures \
        --outputdir patched-fonts \
        "$font"
    done
  '';

  installPhase = ''
    mkdir -p "$out/share/fonts/opentype"
    cp patched-fonts/*.otf "$out/share/fonts/opentype/"
  '';
}
