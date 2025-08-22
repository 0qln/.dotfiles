# Utils for home-manager modules.
{
  lib,
  pkgs,
  config,
  osConfig,
  flake,
  ...
}:
rec {
  # some reading material on fetchers:
  # https://ryantm.github.io/nixpkgs/builders/fetchers/

  # https://nixos.wiki/wiki/Cursor_Themes
  mkCursorPack =
    {
      url,
      hash,
      name,
      size,
    }:
    {
      gtk.enable = true;
      x11.enable = true;
      inherit name;
      inherit size;
      package = pkgs.runCommand "moveUp" { } ''
        mkdir -p $out/share/icons
        ln -s ${
          pkgs.fetchzip {
            inherit url;
            inherit hash;
          }
        } $out/share/icons/${name}
      '';
    };

  mkCursorPackLocal =
    {
      url,
      fileName,
      archiveHash,
      packName,
      packHash,
      size,
    }:
    let
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
  mkCursorPackWin =
    {
      url,
      hash,
      name,
      size,
      # TODO: the default name mapping can be improved...
      nameMap ?
        let
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
        in
        {
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
          "busy" = [ "watch" ];
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
          "alt" = [ "center_ptr" ];
        },
    }:
    let
      # we rename here bc sometimes the name of the download is the url part like "/cursor-downloadset.php?id=neco-arc"
      # and when that happens the mkDerviation.src fucks itself over
      winPack = pkgs.runCommand "rename" { } ''
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
        buildPhase = ''
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
              lib.mapAttrsToList (k: v: ''
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
              '') nameMap
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
    in
    {
      gtk.enable = true;
      x11.enable = true;
      inherit name;
      inherit size;
      package = pack;
    };

  # workaround for making the config writable:
  # while this works... it is incredibly ugly :(
  # home.activation = {
  # replaceWithTarget = lib.hm.dag.entryAfter [ "writeBoundry" ] ''
  #   run cp -RL "${config.xdg.configHome}/todoist" "${config.xdg.configHome}/todoist.contents"
  #   run rm -rf "${config.xdg.configHome}/todoist"
  #   run mv "${config.xdg.configHome}/todoist.contents" "${config.xdg.configHome}/todoist"
  #   run chmod 755 "${config.xdg.configHome}/todoist"
  #   run chmod 600 "${config.xdg.configHome}/todoist/config.json"

  #mkSecretLink =
  #  {
  #    # the secret file. can also contain a path e.g. todoist/todoist-token
  #    secret,
  #    # full destination path (e.g., "${config.xdg.configHome}/todoist/config.json")
  #    destPath,
  #    # home manager depdency graph entry point
  #    deps ? [ "writeBoundary" ],
  #  }:
  #  lib.hm.dag.entryAfter deps ''
  #    #!${pkgs.bash}/bin/bash
  #    dst="${destPath}"
  #    src="$XDG_RUNTIME_DIR/secrets/${secret}"
  #    if [[ ! -e "$dst" ]]; then
  #      mkdir -p "$(dirname "$dst")"
  #      ln -s "$src" "$dst"
  #    fi
  #  '';

  #mkForceSecretLink =
  #  {
  #    secret, # can also contain a path e.g. todoist/todoist-token
  #    destPath, # Full destination path (e.g., "${config.xdg.configHome}/todoist/config.json")
  #    deps ? [ "writeBoundary" ],
  #  }:
  #  lib.hm.dag.entryAfter deps ''
  #    #!${pkgs.bash}/bin/bash
  #    dst="${destPath}"
  #    src="$XDG_RUNTIME_DIR/secrets/${secret}"
  #    if [[ ! -e "$dst" ]]; then
  #      rm "$("$dst")"
  #    fi
  #    ln -s "$src" "$dst"
  #  '';

  mkForceCopySecret =
    {
      secret, # can also contain a path e.g. todoist/todoist-token
      destPath, # Full destination path (e.g., "${config.xdg.configHome}/todoist/config.json")
      deps ? [ "writeBoundary" ],
    }:
    lib.hm.dag.entryAfter deps ''
      #!${pkgs.bash}/bin/bash
      dst="${destPath}"
      src="$XDG_RUNTIME_DIR/secrets/${secret}"
      if [[ -e "$dst" ]]; then
        run rm -r "$dst"
      fi
      # the todoist-cli cannot handle soft symlinks. hardlinks break
      # break because XDG_RUNTIME_DIR is usually /run/user/..., which is
      # an in-memory filesystem.
      # so we have no other option but to copy :(
      # (we could bind the file systems, but that's just overkill)
      run cp -Lrp "$src" "$dst"
    '';

  mkCopy =
    {
      source,
      destPath, # Full destination path (e.g., "${config.xdg.configHome}/todoist/config.json")
      newMode ? "700",
      deps ? [ "writeBoundary" ],
    }:
    lib.hm.dag.entryAfter deps ''
      #!${pkgs.bash}/bin/bash
      dst="${destPath}"
      src="${source}"
      if [[ -e "$dst" ]]; then
        run rm -r "$dst"
      fi
      run cp -Lrp "$src" "$dst"
      chmod ${newMode} $dst
    '';

  userRuntimeDir = "/run/user/${toString osConfig.users.users.${config.home.username}.uid}";

  #TODO: use this and don't hardcode the root path: https://github.com/srid/flake-root
  #TODO: not sure this still works as inteded after refactoring
  #
  # Use this when trying to make a symlink that does not link to the store. e.g:
  # ```
  # # (in home.nix file:)
  # # this makes a soft link in in /home/{user}/.config/nvim
  # # that points to a nvim/ directory in the flake.)
  # home.file.".config/nvim" = {
  #     source = config.lib.file.mkOutOfStoreSymlink (runtimePath ./nvim);
  #     recursive = true;
  # };
  # ```
  # Notice, however, that stuff like nvim-mason, that wants to download and run
  # language servers (binaries) will not work due to how NixOS works...
  #
  # source: https://github.com/nix-community/home-manager/issues/257#issuecomment-1646557848
  # related: https://discourse.nixos.org/t/neovim-config-read-only/35109/10
  runtimeRoot = "/home/${config.home.username}/.dotfiles"; # path to flake
  runtimePath =
    path:
    let
      rootStr = toString flake; # current flake path
      pathStr = toString path; # path path
    in
    assert lib.assertMsg (lib.hasPrefix rootStr pathStr) "${pathStr} does not start with ${rootStr}";
    runtimeRoot + lib.removePrefix rootStr pathStr;
}
