{
  pkgs,
  lib,
  monitors,
  ...
}: let
  todoist-quick-add = pkgs.callPackage ../../todoist/todoist-quick-add.nix {};

  #TODO: pull these meta-variables up into some module
  fileManager = "lf";
  mainMod = "SUPER";
  terminal = "kitty";
in {
  wayland.windowManager.hyprland.settings = {
    # For some reason hardware_cursors draws the cursor like 250px
    # to the left and some other issues...
    # fix source: https://github.com/hyprwm/Hyprland/issues/8852
    cursor = {
      no_hardware_cursors = "true";
    };

    input = {
      kb_layout = "us";
      kb_options = "compose:ralt";
      follow_mouse = 1;
      sensitivity = 0;
      accel_profile = "flat";
      force_no_accel = true;
      touchpad = {
        natural_scroll = false;
      };
    };

    bind = [
      # Application shortcuts
      "${mainMod}, Q, exec, ${terminal}"
      "${mainMod}, C, exec, hyprpicker | wl-copy"
      "${mainMod}, DELETE, killactive"
      "${mainMod}, E, exec, ${fileManager}"
      "${mainMod}, V, togglefloating"
      "${mainMod}, P, pseudo"
      "${mainMod}, J, togglesplit"
      "${mainMod}, O, exec, obsidian"
      "${mainMod}, E, exec, splatmoji --disable-emoji-db copy" # copypaste or type commands don't work; type bc ydotool is goofy and the prior idk why
      "${mainMod}, Z, exec, zen"
      "${mainMod}, B, exec, ${terminal} -e bluetoothctl"
      "${mainMod}, T, exec, [float; center; size 600 100] ${terminal} --class todoist-popup -e ${lib.getExe todoist-quick-add}"
      #"CTRL, SPACE, exec, [float; center; size 600 100] ${pkgs.writeShellScript "todoist-quick-add-shortcut" ''
      #  #!${pkgs.bash}/bin/bash
      #  active_class=$(hyprctl activewindow -j | jq -r '.class')
      #  if [[ "$active_class" == *"Minecraft"* ]]; then
      #      # TODO: why does this not work? sending stuff like F2 works, but not ctrl+space...
      #      # hyprctl dispatch sendshortcut CTRL, SPACE, class:^Minecraft.*$
      #      # hyprctl dispatch sendshortcut ,SPACE, class:^Minecraft.*$
      #      exit 0
      #  else
      #      ${terminal} --class todoist-popup -e ${lib.getExe todoist-quick-add}
      #  fi
      #''}"

      # using dispatchers here, since setting the window rules for zen does not work...
      # "${mainMod}, M, exec, [float; center; size 600 600] zen-twilight --new-window music.youtube.com"
      #  # && sleep 1 && hyprctl dispatch movewindow mon:${monitors.left} && hyprctl dispatch pseudo && hyprctl dispatch resizeactive exact 80% 30%
      # "${mainMod} ALT, M, "
      # "${mainMod} ALT, M, "
      # "${mainMod} ALT, M, "
      # hyprland can't handle zen so we using an electron app grahh
      "${mainMod}, M, exec, youtube-music"

      # app/window search bar
      "${mainMod}, SPACE, exec, rofi -show combi -modes \"combi,ssh,recursivebrowser\" -combi-modes \"window,run,drun\""

      # file searchbar
      "${mainMod}, F, exec, rofi -show recursivebrowser"

      # ssh connections search bar
      "${mainMod}, S, exec, rofi -show ssh"

      # rebuild current dotfiles
      # does not work for whatever reason...
      # "${mainMod}, N, exec, [float; center; size 50% 50%] ${terminal} -e bash -c 'cd ~/.dotfiles && git add . && sudo nixos-rebuild switch --flake ~/.dotfiles#${host-name} ; exec bash'"

      # Focus movement
      "ALT SHIFT, H, movefocus, l"
      "ALT SHIFT, L, movefocus, r"
      "ALT SHIFT, K, movefocus, u"
      "ALT SHIFT, J, movefocus, d"
      "ALT SHIFT, N, focuswindow, floating"

      # Workspace navigatio
      "ALT SHIFT, 1, workspace, 1"
      "ALT SHIFT, 2, workspace, 2"
      "ALT SHIFT, 3, workspace, 3"
      "ALT SHIFT, 4, workspace, 4"
      "ALT SHIFT, 5, workspace, 5"
      "ALT SHIFT, 6, workspace, 6"
      "ALT SHIFT, 7, workspace, 7"
      "ALT SHIFT, 8, workspace, 8"
      "ALT SHIFT, 9, workspace, 9"
      "ALT SHIFT, 0, workspace, 10"

      # Move windows to workspaces
      "CTRL ALT, 1, movetoworkspace, 1"
      "CTRL ALT, 2, movetoworkspace, 2"
      "CTRL ALT, 3, movetoworkspace, 3"
      "CTRL ALT, 4, movetoworkspace, 4"
      "CTRL ALT, 5, movetoworkspace, 5"
      "CTRL ALT, 6, movetoworkspace, 6"
      "CTRL ALT, 7, movetoworkspace, 7"
      "CTRL ALT, 8, movetoworkspace, 8"
      "CTRL ALT, 9, movetoworkspace, 9"
      "CTRL ALT, 0, movetoworkspace, 10"

      "CTRL ALT, H, movewindow, l"
      "CTRL ALT, J, movewindow, d"
      "CTRL ALT, K, movewindow, u"
      "CTRL ALT, L, movewindow, r"

      "CTRL ALT, P, pseudo"
      "CTRL ALT, C, centerwindow"
      "CTRL ALT, B, togglefloating"
      "CTRL ALT, M, fullscreenstate, 0"
      "CTRL ALT, N, fullscreenstate, 1"
      "CTRL ALT, F, fullscreenstate, 2"
      "CTRL SHIFT, M, fullscreenstate, -1, 0"
      "CTRL SHIFT, N, fullscreenstate, -1, 1"
      "CTRL SHIFT, F, fullscreenstate, -1, 2"

      # Special workspace
      "ALT SHIFT, S, togglespecialworkspace, magic"
      "CTRL ALT, S, movetoworkspace, special:magic"

      # Multimedia keys
      ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
      ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ", XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
      ", XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
      ", XF86AudioNext, exec, playerctl next"
      ", XF86AudioPause, exec, playerctl play-pause"
      ", XF86AudioPlay, exec, playerctl play-pause"
      ", XF86AudioPrev, exec, playerctl previous"
    ];

    # Mouse bindings
    bindm = [
      "${mainMod}, mouse:272, movewindow"
      "${mainMod}, mouse:273, resizewindow"
    ];
  };
}
