{ pkgs, ... }:
let
  previewer = import ./previewer.nix { inherit pkgs; };
  cleaner = import ./cleaner.nix { inherit pkgs; };
  lf-ueberzug = import ./lf-ueberzug.nix { inherit pkgs; };
in
{
  home.packages = with pkgs; [

    # TODO:
    # `Gtk-Message: 20:24:39.360: Failed to load module "colorreload-gtk-module"`
    # even though gtk 3 is installed and in the path
    dragon-drop
    gtk3

    unzip
    mescc-tools-extra # untar
    gnutar
    unrar-wrapper
    p7zip

    ueberzugpp

    fzf

    file

    xdg-utils

    poppler-utils # pdftotext

    highlight

    chafa

    lf-ueberzug
  ];

  imports = [
    ../zoxide
    ../trashy
  ];

  # https://home-manager-options.extranix.com/?query=lf&release=release-25.05

  programs.lf = {

    enable = true;

    settings = {
      hidden = true;
      ignorecase = true;
      icons = true;
      scrolloff = 3;
      truncatechar = "⋯";
    };

    extraConfig = ''
      set previewer ${previewer}/bin/previewer
      set cleaner ${cleaner}/bin/cleaner
    '';

    commands = {

      dragon-out = ''%${pkgs.xdragon}/bin/xdragon -a -x "$fx"'';

      open = ''
        &{{
          case $(file --mime-type -Lb $f) in
            text/*) lf -remote "send $id \$nvim \$fx";;
            *) xdg-open "$f"
          esac
        }}
      '';

      mkdir = ''
        ''${{
          printf "Directory Name: "
          read DIR
          mkdir $DIR
        }}
      '';

      mkfile = ''
        ''${{
          printf "File Name: "
          read FILE
          $EDITOR $FILE
        }}
      '';

      fzf_jump = ''
        ''${{
          res="$(find . -maxdepth 1 | fzf --reverse --header='Jump to location')"
          if [ -n "$res" ]; then
              if [ -d "$res" ]; then
                  cmd="cd"
              else
                  cmd="select"
              fi
              res="$(printf '%s' "$res" | sed 's/\\/\\\\/g;s/"/\\"/g')"
              lf -remote "send $id $cmd \"$res\""
          fi
        }}
      '';

      fzf_search = ''
        ''${{
          RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
          res="$(
            FZF_DEFAULT_COMMAND="$RG_PREFIX '''" \
              fzf --bind "change:reload:$RG_PREFIX {q} || true" \
              --ansi --layout=reverse --header 'Search in files' \
              | cut -d':' -f1 | sed 's/\\/\\\\/g;s/"/\\"/g'
          )"
          [ -n "$res" ] && lf -remote "send $id select \"$res\""
        }}
      '';

      z-jump = ''
        ''${{
          ZLUA_SCRIPT="$ZDOTDIR/plugins/z.lua/z.lua"
          lf -remote "send ''${id} cd \"$($ZLUA_SCRIPT -e $@ | sed 's/\\/\\\\/g;s/"/\\"/g')\""
        }}
      '';

      unarchive = ''
        ''${{
          case "$f" in
              *.zip) unzip "$f" ;;
              *.rar) unrar x "$f" ;;
              *.tar.gz) tar -xzvf "$f" ;;
              *.tar.bz2) tar -xjvf "$f" ;;
              *.tar) tar -xvf "$f" ;;
              *.7z) 7z e "$f" ;;
              *) echo "Unsupported format" ;;
          esac
        }}
      '';

      trash = ''
        ''${{
          files=$(printf "$fx" | tr '\n' ';')
          while [ "$files" ]; do
            file=''${files%%;*}

            trash put "$(basename "$file")"
            if [ "$files" = "$file" ]; then
              files='''
            else
              files="''${files#*;}"
            fi
          done
        }}
      '';

    };

    keybindings = {

      "c" = null;
      "d" = null;

      "Z" = "push :z-jump<space>-I<space>";
      "zb" = "push :z-jump<space>-b<space>";
      "zz" = "push :z-jump<space>";

      "f" = null;
      "ff" = "fzf_jump";
      "f/" = "fzf_search";

      "." = "set hidden!";

      "dd" = "trash";
      "u" = "$trash restore -r 0";

      "p" = "paste";
      "x" = "cut";
      "y" = "copy";

      "<enter>" = "open";

      "R" = "reload";

      "m" = null;
      "mf" = "mkfile";
      "md" = "mkdir";

      "au" = "unarchive";

    };
  };

}
