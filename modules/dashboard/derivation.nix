{
  name,
  pkgs,
  servicePkgs ? [],
}: let
  lib =
    pkgs.writeScriptBin "${name}_lib"
    # bash
    ''
      d-art() {
          clear
          echo ""
          cat ${./unix.art}
          echo ""
          read _
      }

      d-btop() {
          btop -p 1 -c ${./btop.conf}
      }

      d-sysfetch() {
          clear
          echo ""
          fastfetch
          read _
      }

      d-nethogs() {
          nethogs -Cas
      }
    '';

  libExe = pkgs.lib.getExe lib;

  bin =
    pkgs.writeScriptBin name
    # bash
    ''
      # Don't allow exits
      trap "" SIGINT SIGQUIT SIGTERM

      source ${libExe}

      backgroundColor='#000000'

      # Setup the dashboard
      # https://stackoverflow.com/a/40009032
      # https://manpages.debian.org/testing/tmux/tmux.1.en.html#select-pane
      # https://man7.org/linux/man-pages/man1/tmux.1.html
      tmux new-session \; \
        set-option status off \; \
        set-option pane-border-style "fg=$backgroundColor, bg=$backgroundColor" \; \
        set-option pane-active-border-style "fg=$backgroundColor, bg=$backgroundColor" \; \
        set-option window-style "bg=$backgroundColor" \; \
        split-window -h  -p 40 \; \
        send-keys 'source ${libExe} && d-btop' C-m \; \
        select-pane -t 0 \; \
        send-keys 'source ${libExe} && d-sysfetch' C-m \; \
        split-window -v -p 66 \; \
        send-keys 'source ${libExe} && d-nethogs' C-m \; \
        split-window -v -p 75 \; \
        send-keys 'source ${libExe} && d-art' C-m \; \
        attach -r # Attatch in readonly mode
    '';

  script = bin.overrideAttrs (old: {
    buildCommand = "${old.buildCommand}\n patchShebangs $out";
  });
in
  pkgs.symlinkJoin {
    inherit name;
    paths = [script] ++ servicePkgs;
    buildInputs = [pkgs.makeWrapper];
    postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
  }
