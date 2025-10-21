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
    };
    config = mkIf cfg.enable {
      programs.direnv = {
        enableBashIntegration = true;
      };

      programs.zoxide = {
        enableBashIntegration = true;
      };

      programs.bash = {
        enable = true;
        # Setting session variables normally is broken when using home-manager ;(
        # context: https://github.com/nix-community/home-manager/issues/1011
        initExtra = ''
          export EDITOR="nvim"
          alias cdf='cd $(fd --hidden --type d | fzf)'
          ${
            if config.programs.kitty.enable
            then "alias ssh='kitten ssh'"
            else ""
          }
          alias la='ll -a'
          alias lg='lazygit'
          alias lf='lf-ueberzug'
          alias nivm='nvim'
          alias clearfetch='clear && ${vars.sysfetcher} && read _'
        '';
        bashrcExtra = ''
          eval "$(direnv hook bash)"
          shopt -s dotglob
          set -o vi
        '';
      };
    };
  }
