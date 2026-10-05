{
  config,
  lib,
  ...
}: let
  inherit (config) vars;
  cfg = config.modules.bash;
in
  with lib; {
    options.modules.bash = {
      enable = mkEnableOption "bash";
      secretFiles = mkOption {
        type = types.attrs;
        default = {};
        example = {
          name = ./secrets.env;
        };
        description = "Attrs of paths to env files that contain environment variables to be imported into the bash session.";
      };
    };
    config = let
      secretName = name: "vars/${name}";
    in
      mkIf cfg.enable {
        programs.direnv = {
          enableBashIntegration = true;
        };

        programs.zoxide = {
          enableBashIntegration = true;
        };

        programs.keychain = {
          enableBashIntegration = true;
        };

        sops.secrets = let
          mkSecret = name: secrets:
            nameValuePair (secretName name) {
              sopsFile = secrets;
              format = "dotenv";
            };
        in
          attrsets.mapAttrs' mkSecret cfg.secretFiles;

        # VS Code runs no shell startup files when it starts its remote server,
        # so the sourcing in initExtra never reaches anything it launches (most
        # visibly Claude Code and the MCP servers it spawns). This hook is read
        # before the server starts. An erroring script blocks VS Code from
        # starting at all, so every line here has to be non-fatal.
        home.file.".vscode-server/server-env-setup".text = ''
          ${
            with lib.strings;
              concatLines (
                attrsets.mapAttrsToList (name: _: let
                  path = config.sops.secrets.${secretName name}.path;
                in ''if [ -r "${path}" ]; then set -a; . "${path}"; set +a; fi'')
                cfg.secretFiles
              )
          }
          true
        '';

        programs.bash = {
          enable = true;
          # Setting session variables normally is broken when using home-manager ;(
          # context: https://github.com/nix-community/home-manager/issues/1011
          initExtra = ''
            export EDITOR="nvim"
            alias cdf='cd $(fd --hidden --type d | fzf)'
            ${
              if config.programs.kitty.enable
              then "alias ssh='kitten ssh --kitten share_connections=no'"
              else ""
            }
            alias la='ll -a'
            alias lg='lazygit'
            # todo: put behind feature guard if ever using ueberzug again
            # alias lf='lf-ueberzug'
            alias nivm='nvim'
            alias clearfetch='clear && ${vars.sysfetcher} && read _'

            ${
              with lib.strings;
                concatLines (
                  map (
                    x: let
                      key = fixedWidthString x "." "";
                      value = fixedWidthString ((x - 1) * 3) "../" "";
                    in ''alias "${key}"="cd ${value}"''
                  ) (lib.lists.range 2 5)
                )
            }

            ${
              with lib.strings;
                concatLines (
                  attrsets.mapAttrsToList (name: _: ''set -a; source "${config.sops.secrets.${secretName name}.path}"; set +a'') cfg.secretFiles
                )
            }
          '';
          bashrcExtra = ''
            shopt -s dotglob

            set -o vi

            eval "$(direnv hook bash)"
          '';
        };
      };
  }
