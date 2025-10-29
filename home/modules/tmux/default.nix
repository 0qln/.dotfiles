{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.tmux;
in
  with lib; {
    options.modules.tmux = {
      enable = mkEnableOption "tmux";
      enableNvimIntegration = config.utils.mkEnableOption "tmux neovim integration" cfg.enable;
      statusline.enable = mkEnableOption "status line";
    };

    config = mkIf cfg.enable {
      programs.tmux = {
        enable = true;
        extraConfig = mkMerge [
          (mkIf (!cfg.statusline.enable) ''
            set-option -g status off
          '')
          (mkIf cfg.enableNvimIntegration ''
            # nvim bindings
            bind-key -T copy-mode-vi 'v' send -X begin-selection
            bind-key -T copy-mode-vi 'y' send -X copy-selection-and-cancel
            bind v split-window -h -c "#{pane_current_path}"
            bind h split-window -v -c "#{pane_current_path}"
            bind s split-window -v -c "#{pane_current_path}"

            # nvim conflicts
            set -sg escape-time 0
            # unbind S-Enter
            # unbind C-,
            # unbind C-`
            set -s extended-keys on
            set-option -g xterm-keys on
            set -as terminal-features 'xterm*:extkeys'
            set-option -g allow-passthrough on
            # all the above does not fucking work. https://github.com/tmux/tmux/wiki/Modifier-Keys#extended-keys

            # nvim image plugin
            set -gq allow-passthrough on
            set -g visual-activity off
          '')
        ];

        keyMode = "vi";

        mouse = true;

        plugins = mkMerge (
          with pkgs; [
            (mkIf cfg.enableNvimIntegration [tmuxPlugins.vim-tmux-navigator])
          ]
        );
      };
    };
  }
