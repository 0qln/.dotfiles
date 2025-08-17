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
