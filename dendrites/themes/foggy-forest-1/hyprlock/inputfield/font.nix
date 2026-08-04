{pkgs ? import <nixpkgs> {}}: {
  name ? "botched-kingjola",
  fontName ? "Kingjola Botched",
  # OpenType ligature substitution rules (using 'liga' so Pango applies them by default)
  rules ? ''
    feature liga {
        lookup RUNE_MORPH {
            # Longest sequences MUST go first!
            sub a a a a a a a a a a by daggerdbl;
            sub a a a a a a a a by dagger;
            sub a a a a a a a by section;
            sub a a a a a a by paragraph;
            sub a a a a a by copyright;
            sub a a a a by registered;
            sub a a a by trademark;
            sub a a by Euro;
        } RUNE_MORPH;
    } liga;
  '',
}:
pkgs.stdenv.mkDerivation {
  pname = name;
  version = "1.0.0";

  src = "${pkgs.kingjola}/share/fonts/";
  dontUnpack = true;

  nativeBuildInputs = [pkgs.fontforge];

  # Write Nix string attributes to temporary files during build
  passAsFile = ["rules" "patchScript"];

  rules = rules;

  patchScript =
    # python
    ''
      import fontforge
      import sys

      font_path = sys.argv[1]
      fea_path = sys.argv[2]
      font_name = sys.argv[3]
      out_path = sys.argv[4]

      # Load original font
      font = fontforge.open(font_path)

      # Merge custom OpenType rules
      font.mergeFeature(fea_path)

      # Update font metadata
      # PostScript fontname MUST NOT contain spaces!
      font.fontname = font_name.replace(" ", "")
      font.familyname = font_name
      font.fullname = font_name

      # Generate patched font
      font.generate(out_path)
      print(f"Successfully generated botched font: {font_name}")
    '';

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/share/fonts/truetype

    cp "$rulesPath" rules.fea

    # Find the font file dynamically regardless of whether it's .ttf or .otf
    INPUT_FONT=$(find "$src" -type f \( -name "*.ttf" -o -name "*.otf" \) | head -n 1)

    # Run patchScript using FontForge's built-in Python engine
    fontforge -lang=py -script "$patchScriptPath" "$INPUT_FONT" "rules.fea" "${fontName}" "$out/share/fonts/truetype/${fontName}.ttf"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    # Output generated directly into $out in buildPhase
    runHook postInstall
  '';
}
