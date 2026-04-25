{
  lib,
  pkgs,
  ...
}:
with lib; {
  config.utils = rec {
    # some reading material on fetchers:
    # https://ryantm.github.io/nixpkgs/builders/fetchers/

    # https://nixos.wiki/wiki/Cursor_Themes
    mkCursorPack = {
      url,
      hash,
      name,
      size,
    }: {
      _customCursor = true;
      gtk.enable = true;
      x11.enable = true;
      inherit name;
      inherit size;
      package = pkgs.runCommand "moveUp" {} ''
        mkdir -p $out/share/icons
        ln -s ${
          pkgs.fetchzip {
            inherit url;
            inherit hash;
          }
        } $out/share/icons/${name}
      '';
    };

    mkCursorPackLocal = {
      url,
      fileName,
      archiveHash,
      packName,
      packHash,
      size,
    }: let
      archive = pkgs.requireFile {
        name = fileName;
        inherit url;
        sha256 = archiveHash;
      };
    in
      mkCursorPack {
        url = "file://${toString archive}";
        hash = packHash;
        name = packName;
        inherit size;
      };

    # Converts a windows pack to linux pack
    # This currently can only handle .zip files
    mkCursorPackWin = {
      url,
      hash,
      name,
      size,
      # TODO: the default name mapping can be improved...
      #
      # mappings from the win states to linux states
      # - https://www.reddit.com/r/linuxquestions/comments/mkvdel/comment/khaxcvt/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
      # - https://www.opendesktop.org/p/999853
      # - https://archive.ph/5NRMb
      nameMap ? let
        diagonal1 = [
          "size_fdiag"
          "top_left_corner"
          "bottom_right_corner"
        ];
        diagonal2 = [
          "size_bdiag"
          "top_right_corner"
          "bottom_left_corner"
        ];
        normal = [
          "left_ptr"
          "default"
          "arrow"
          "top_left_arrow"
          "left_arrow"
        ];
        move = [
          "fleur"
          "move"
          "all-scroll"
          "dnd-move"
        ];
        hand = [
          "hand1"
          "hand"
          "pointer"
          "pointing_hand"
        ];
        horizontal = [
          "sb_h_double_arrow"
          "size_hor"
          "h_double_arrow"
        ];
        vertical = [
          "sb_v_double_arrow"
          "size_ver"
          "v_double_arrow"
        ];
      in {
        "^\\s*normal\\s*$" = normal;
        "^\\s*$" = normal;

        "^\\s*help\\s*$" = [
          "question_arrow"
          "help"
        ];

        "^\\s*text\\s*$" = [
          "xterm"
          "text"
        ];

        "^\\s*busy\\s*$" = [
          "watch"
        ];

        "^\\s*work\\s*$" = [
          "left_ptr_watch"
          "half-busy"
          "progress"
        ];

        "^\\s*vertical\\s*$" = vertical;
        "^\\s*vert\\s*$" = vertical;

        "^\\s*horizontal\\s*$" = horizontal;
        "^\\s*horz\\s*$" = horizontal;

        "^\\s*diagonal( resize)?\\s*$" = diagonal1;
        "^\\s*diagonal( resize)? 1\\s*$" = diagonal1;
        "^\\s*dgn1\\s*$" = diagonal1;

        "^\\s*diagonal( resize)? 2\\s*$" = diagonal2;
        "^\\s*dgn2\\s*$" = diagonal2;

        "^\\s*precision\\s*$" = [
          "crosshair"
          "cross"
          "tcross"
          "color-picker"
        ];

        "^\\s*hand\\s*$" = hand;
        "^\\s*move\\s*$" = move;

        "^\\s*link\\s*$" = [
          "hand2"
          "link"
          "alias"
          "dnd-link"
        ];

        "^\\s*unavailable\\s*$" = [
          "crossed_circle"
          "not-allowed"
          "forbidden"
        ];

        "^\\s*alt\\s*$" = ["center_ptr"];
      },
    }: let
      # we rename here bc sometimes the name of the download is the url part like "/cursor-downloadset.php?id=neco-arc"
      # and when that happens the mkDerviation.src fucks itself over
      winPack = pkgs.runCommand "rename" {} ''
        mkdir -p $out
        cp ${
          pkgs.fetchurl {
            inherit url;
            inherit hash;
          }
        } $out/winPack.zip
      '';

      pack = pkgs.stdenv.mkDerivation {
        inherit name;
        src = winPack;
        buildInputs = with pkgs; [
          win2xcur
          unzip
          python3
        ];
        buildPhase = let
          getCommonPrefix =
            pkgs.writers.writePython3Bin "get-common-prefix" {}
            ''
              import os
              files = [f for f in os.listdir(".") if os.path.isfile(f)]
              if not files:
                  raise Exception(f"Could not read files: {files}")
              prefix = os.path.commonprefix(files)
              print(prefix if prefix else "")
            '';

          # I don't got the nerves to deal with posix regex so here we fucking go :D
          regexMatches =
            pkgs.writers.writePython3Bin "get-common-prefix" {}
            ''
              import re
              import sys

              regex = sys.argv[2]
              test_str = sys.argv[1]
              result = re.search(regex, test_str)

              exit(0 if result else 1)
            '';
        in
          # sh
          ''
            unzip winPack.zip -d winPack

            iconsDir="$out/share/icons/${name}"
            mkdir -p "$iconsDir/cursors"

            (
              # sometimes the files are at the zip root...
              cd winPack

              # sometimes they are a level deeper...
              if [ -d "${name}" ]; then
                cd "${name}"
              fi

              # try unpacking >w< 🎁
              win2xcur *.{ani,cur} -o "$iconsDir/cursors"
            )

            # name mapping
            (
              cd "$iconsDir/cursors"

              common_prefix="$(${getExe getCommonPrefix})"

              echo "Common Prefix: '$common_prefix'"

              ${lib.concatStringsSep "\n" (
              lib.mapAttrsToList (
                winPat: linuxNames: let
                  copyCursorTo = x:
                  #bash
                  ''[ "$orig_file" != "${x}" ] && cp "$orig_file" "${x}"'';
                in
                  # sh
                  ''
                    echo "Scanning for pattern: '${winPat}'"

                    # see if any of the windows cursor file names matches any pattern
                    for file in * ; do
                      orig_file="$file"

                      # compare case-insensitive
                      file="''${file#"$common_prefix"}" # strip common prefix
                      file="''${file,,}" # convert to lowercase

                      # if they match, copy the cursor to the output dir under the linux names.
                      if "${getExe regexMatches}" "$file" "${winPat}"; then
                        echo "[x] Found match (Original File: '$orig_file', Processed File: '$file')"
                        ${lib.concatMapStringsSep "\n" copyCursorTo linuxNames}
                      else
                        echo "[o] No match (Original File: '$orig_file', Processed File: '$file')"
                      fi

                    done
                  ''
              )
              nameMap
            )}
            )

            # index.theme
            touch "$iconsDir/index.theme"
            cat > "$iconsDir/index.theme" << EOF
            [Icon Theme]
            Name=${name}
            Comment=Windows cursor theme converted for Linux
            EOF
          '';
        installPhase = ":";
      };
    in {
      gtk.enable = true;
      x11.enable = true;
      inherit name;
      inherit size;
      package = pack;
    };
  };
}
