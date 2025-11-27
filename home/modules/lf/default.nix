{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.lf;
  cleaner = import ./cleaner.nix {inherit pkgs;};
  lf-ueberzug = import ./lf-ueberzug.nix {inherit pkgs;};
in {
  options.modules.lf = {
    enable = mkEnableOption "lf fileexplorer";
    previewer.backend = mkOption {
      type = types.enum ["chafa" "ueberzug"];
      default = "chafa";
    };
  };

  imports = [
    #TODO: feature gate for zoxide shortcuts or enable in this config idk
    ../zoxide
  ];

  config = mkIf cfg.enable {
    home.packages = with pkgs; (mkMerge [
      [
        dragon-drop

        unzip
        mescc-tools-extra # untar
        gnutar
        unrar-wrapper
        p7zip

        fzf

        file

        xdg-utils

        poppler-utils # pdftotext

        highlight

        trashy
      ]
    ]);

    # https://home-manager-options.extranix.com/?query=lf&release=release-25.05

    xdg.configFile."lf/icons".source = ./icons;

    programs.bash.initExtra = let
      wrapper = pkgs.writeShellApplication {
        name = "lf-wrapper";
        text = builtins.readFile ./lf-ueberzug.sh;
      };
    in ''
      alias lf='${getExe wrapper}'
    '';

    programs.lf = {
      enable = true;

      settings = {
        hidden = true;
        ignorecase = true;
        icons = true;
        scrolloff = 3;
        truncatechar = "⋯";
      };

      extraConfig = let
        previewer = pkgs.writeShellApplication {
          name = "lf-previewer";
          runtimeInputs = with pkgs; [
            (mkIf (cfg.previewer.backend == "ueberzug") [ueberzugpp])
            (mkIf (cfg.previewer.backend == "chafa") [chafa])
          ];
          text = ''
            chafa --fit-width "$width" "$path"
          '';
        };
      in ''
        set previewer ${getExe previewer}
        set cleaner ${getExe cleaner}
      '';

      commands = {
        dragon-out = ''%${getExe pkgs.dragon-drop} -a -x "$fx"'';

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

        copy-name = ''$basename "$f" | wl-copy'';
        copy-path = ''$echo "$f" | wl-copy'';
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
        "Y" = "copy-name";
        "<C-y>" = "copy-path";
        "o" = "dragon-out";

        "<enter>" = "open";

        "R" = "reload";

        "m" = null;
        "mf" = "mkfile";
        "md" = "mkdir";

        "au" = "unarchive";
      };
    };
  };
}
