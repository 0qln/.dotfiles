#!/usr/bin/env bash

# Don't allow exits
trap '' SIGINT SIGQUIT SIGTERM

# Setup the dashboard
# https://stackoverflow.com/a/40009032
# https://manpages.debian.org/testing/tmux/tmux.1.en.html#select-pane
# https://man7.org/linux/man-pages/man1/tmux.1.html
tmux new-session \; \
  split-window -h \; \
  send-keys 'btop' C-m \; \
  select-pane -t 0 \; \
  send-keys 'neofetch' C-m \; \
  split-window -v -p 60 \; \
  send-keys 'nethogs -a' C-m \; \
  attach -r # Attatch in readonly mode
