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
      in {
        "normal" = [
          "left_ptr"
          "default"
          "arrow"
          "top_left_arrow"
          "left_arrow"
        ];
        "help" = [
          "question_arrow"
          "help"
        ];
        "text" = [
          "xterm"
          "text"
        ];
        "busy" = ["watch"];
        "work" = [
          "left_ptr_watch"
          "half-busy"
          "progress"
        ];
        "vertical" = [
          "sb_v_double_arrow"
          "size_ver"
          "v_double_arrow"
        ];
        "horizontal" = [
          "sb_h_double_arrow"
          "size_hor"
          "h_double_arrow"
        ];
        #TODO: remove common prefix (e.g. 'Maomao') and go for full matches
        "^diagonal (resize)?$" = diagonal1;
        "^diagonal (resize)? 1$" = diagonal1;
        "^diagonal (resize)? 2$" = diagonal2;
        "move" = [
          "fleur"
          "move"
          "all-scroll"
          "dnd-move"
        ];
        "precision" = [
          "crosshair"
          "cross"
          "tcross"
          "color-picker"
        ];
        "hand" = [
          "hand1"
          "hand"
          "pointer"
          "pointing_hand"
        ];
        "link" = [
          "hand2"
          "link"
          "alias"
          "dnd-link"
        ];
        "unavailable" = [
          "crossed_circle"
          "not-allowed"
          "forbidden"
        ];
        "alt" = ["center_ptr"];
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
        ];
        buildPhase =
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
              ${lib.concatStringsSep "\n" (
              lib.mapAttrsToList (
                k: v:
                # sh
                ''
                  # either a perfect match
                  if [ -f "${k}" ]; then
                    ${lib.concatMapStringsSep "\n" (v: ''[ "$winFile" != "${v}" ] && cp "$winFile" "${v}"'') v}
                  fi
                  # or a partial match e.g. $file='neco-arc normal'
                  for file in * ; do
                    pat="${k}"
                    lowercase_pat="''${pat,,}"
                    lowercase_file="''${file,,}"
                    if [[ "$lowercase_file" =~ "$lowercase_pat" ]]; then
                      ${lib.concatMapStringsSep "\n" (v: ''[ "$file" != "${v}" ] && cp "$file" "${v}"'') v}
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
