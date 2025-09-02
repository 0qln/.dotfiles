{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    extraConfig = ''
      bind-key -T copy-mode-vi 'v' send -X begin-selection
      bind-key -T copy-mode-vi 'y' send -X copy-selection-and-cancel
      bind v split-window -h -c "#{pane_current_path}"
      bind h split-window -v -c "#{pane_current_path}"
      bind s split-window -v -c "#{pane_current_path}"
    '';

    keyMode = "vi";

    mouse = true;

    plugins = with pkgs; [
      tmuxPlugins.vim-tmux-navigator
    ];
  };
}
