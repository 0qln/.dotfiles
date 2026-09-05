{pkgs, ...}: {
  config.utils = {
    importKittyTheme = themeText: let
      # 1. Split the text into individual lines
      lines = builtins.filter builtins.isString (builtins.split "\n" themeText);

      # 2. Parse each line into a { name, value } pair
      parseLine = line: let
        # Regex breakdown:
        # [ \t]* -> Ignores leading whitespace
        # ([a-zA-Z0-9_-]+) -> Group 1: Captures the key
        # [ \t]+           -> Matches the whitespace between key and value
        # ([^ \t]+)        -> Group 2: Captures the value (stops at whitespace)
        # .* -> Ignores trailing text (like inline comments)
        match = builtins.match "[ \t]*([a-zA-Z0-9_-]+)[ \t]+([^ \t]+).*" line;
      in
        if match != null
        then {
          name = builtins.elemAt match 0;
          value = builtins.elemAt match 1;
        }
        else null;

      # 3. Filter out comments/empty lines (nulls) and convert to an attribute set
      validPairs = builtins.filter (x: x != null) (map parseLine lines);
    in
      builtins.listToAttrs validPairs;

    genWpeScreenshot = {
      wallpaperId,
      workshopPath ? "~/.local/share/Steam/steamapps/workshop/content/431960",
      outputName ? "wallpaper-static.png",
    }:
      pkgs.runCommand "wpe-screenshot-${wallpaperId}" {
        nativeBuildInputs = with pkgs; [linux-wallpaperengine];
      } ''
        # Note: This requires the environment to have access to the wallpaper files.
        # In a pure Nix build, we'd need to provide the wallpaper source as an input.

        export HOME=$(mktemp -d)

        echo "Attempting to render wallpaper ID: ${wallpaperId}"

        # We use the 'wallpaperengine-linux-cli' to capture a frame.
        # --render-offline is a common flag for headless rendering if supported,
        # otherwise we point it to the directory of the specific ID.

        # todo: use hardware info from config or input
        linux-wallpaperengine ${wallpaperId} --window 0x0x1920x1080 --screenshot "$out"
        # wallpaperengine-linux-cli \
        #   --screenshot \
        #   --scene "${workshopPath}/${wallpaperId}/scene.pkg" \
        #   --output "$out"
      '';

    resizeImage = width: height: src: name: let
      w = toString width;
      h = toString height;
    in
      pkgs.stdenv.mkDerivation {
        inherit src name;
        dontUnpack = true;
        buildInputs = [pkgs.imagemagick];
        buildPhase = ''
          mkdir -p $out/share/
          convert $src -resize ${w}x${h} $out/share/${name}
        '';
      };

    wallhavenUrl = name: let
      match = builtins.match "wallhaven-(.{2}).*" name;
      prefix =
        if match != null
        then builtins.elemAt match 0
        else null;
    in
      if prefix == null
      then throw "Invalid wallhaven wallpaper name: ${name}. Expected format: wallhaven-<id>.<type>, where len(id) > 1."
      else "https://w.wallhaven.cc/full/${prefix}/${name}";
  };
}
