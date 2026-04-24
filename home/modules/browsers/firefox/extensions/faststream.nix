{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  ...
}:
buildNpmPackage rec {
  pname = "faststream-ff";
  version = "1.3.76";

  src = fetchFromGitHub {
    owner = "Andrews54757";
    repo = "FastStream";
    rev = "v${version}";
    hash = lib.fakeHash; # See note below
  };

  # This handles the `npm install --only=dev` requirement implicitly
  npmDepsHash = lib.fakeHash; # See note below

  # Firefox requires the Addon ID to match the extension's manifest or it will be rejected.
  # If the developer specifies a browser_specific_settings.gecko.id, use that here.
  addonId = "faststream@andrews54757";

  # By default, `buildNpmPackage` will run `npm run build`, outputting to the `built/` directory.

  installPhase = ''
    runHook preInstall

    # Set up the standard Mozilla extension directory path
    dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
    mkdir -p "$dst"

    # FastStream's build process generates multiple zips.
    # Grab the `firefox-libre` zip (intended for manual/store-free installations)
    # and copy it to the destination directory as an `.xpi` file.
    cp built/firefox-libre-*.zip "$dst/${addonId}.xpi"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Stream videos without buffering in the browser";
    homepage = "https://github.com/Andrews54757/FastStream";
    platforms = platforms.all;
  };
}
