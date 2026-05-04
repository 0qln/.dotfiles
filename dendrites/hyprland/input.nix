{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  todoist-quick-add = pkgs.callPackage ../../todoist/todoist-quick-add.nix {};
  inherit (config.vars) terminal fileexplorer;
  cfg = config.modules.hyprland.input;
in {
  options.modules.hyprland.input = {
    submaps = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          key = mkOption {type = types.str;};
          binds = mkOption {
            type = types.listOf (types.either types.str (types.submodule {
              options = {
                flags = mkOption {
                  type = types.str;
                  default = "";
                };
                keys = mkOption {type = types.str;};
                dispatch = mkOption {type = types.str;};
                reset = mkOption {
                  type = types.bool;
                  default = false;
                };
              };
            }));
          };
        };
      });
    };
    mainMod = mkOption {
      type = types.str;
      default = "SUPER";
    };
  };

  config = let
    inherit (cfg) mainMod;
  in {
    wayland.windowManager.hyprland = {
      settings = {
        # For some reason hardware_cursors draws the cursor like 250px
        # to the left and some other issues...
        # fix source: https://github.com/hyprwm/Hyprland/issues/8852
        cursor = {
          no_hardware_cursors = "true";
        };

        input = let
          inherit (config.modules) input;
        in
          mkMerge [
            {
              kb_layout = "us";
              kb_options = "compose:ralt";
              follow_mouse = 1;
              sensitivity = input.mouse.speed;
              touchpad = {
                natural_scroll = true;
                scroll_factor = 1.0;
              };
            }
            (mkIf (!input.mouse.accel) {
              accel_profile = "flat";
              force_no_accel = true;
            })
          ];

        bind = mkMerge [
          [
            # Application shortcuts
            "${mainMod}, Q, exec, ${terminal}"
            "${mainMod}, C, exec, hyprpicker | wl-copy"
            "${mainMod}, DELETE, killactive"
            "${mainMod}, E, exec, ${fileexplorer}"
            "${mainMod}, V, togglefloating"
            "${mainMod}, P, pseudo"
            "${mainMod}, J, togglesplit"
            "${mainMod}, O, exec, obsidian"
          ]
          (mkIf config.modules.splatmoji.enable [
            # copypaste or type commands don't work; type bc ydotool is goofy and the prior idk why
            "${mainMod}, E, exec, splatmoji --disable-emoji-db copy"
          ])
          (mkIf config.modules.browser.firefox.zen.enable [
            "${mainMod}, Z, exec, zen"
          ])
          [
            "${mainMod}, B, exec, ${terminal} -e bluetoothctl"
          ]
          (mkIf config.modules.todoist.quickAdd.enable (let
            exec = {
              # TODO:
              # impl where:
              #
              # neovim plugin with completion for stuff like
              # @... (todoist labels | awk '{print $2}')
              # #... (todoist projects | awk '{print $2}')
              #
              # then create a {terminal} with a scratch buffer:
              # echo "daily" > /tmp/neovim_buffer.txt && $EDITOR /tmp/neovim_buffer.txt && cat /tmp/neovim_buffer.txt
              #

              # terminal
              "terminal" = "[float; center; size 600 100] ${terminal} --class todoist-popup -e ${lib.getExe todoist-quick-add}";

              # rofi
              # can't use dmenu, because it outputs the selection, so we cannot get the whole task the user entered.
              "rofi" = "rofi -show run -config ${config.modules.todoist.quickAdd.rofi.configFile}";
            };
          in [
            "${mainMod}, T, exec, ${exec.${config.modules.todoist.quickAdd.impl}}"
          ]))
          [
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
          ]
        ];

        # Mouse bindings
        bindm = [
          "${mainMod}, mouse:272, movewindow"
          "${mainMod}, mouse:273, resizewindow"
        ];
      };

      extraConfig = with strings;
        concatLines (
          [
            ''
              # some config
            ''
          ]
          ++
          # Submaps
          (attrsets.mapAttrsToList
            (
              name: {
                key,
                binds,
              }:
                concatStrings [
                  ''
                    bind = ${mainMod}, ${key}, submap, ${name}
                    submap = ${name}
                  ''
                  (
                    concatMapStrings (
                      bind:
                        if (isString bind)
                        then ''
                          ${bind}
                        ''
                        else let
                          escape = strings.escape ["\"" "\\"];
                          dispatch = ''hyprctl dispatch "${escape bind.dispatch}"'';
                          reset =
                            if bind.reset
                            then "hyprctl dispatch submap reset"
                            else ":";
                          action = ''exec, bash -c "${escape dispatch} && ${reset}"'';
                        in ''
                          bind${bind.flags} = ${bind.keys}, ${action}
                        ''
                    )
                    binds
                  )
                  ''
                    bind = , escape, submap, reset
                    bind = , catchall, submap, reset
                    submap = reset
                  ''
                ]
            )
            cfg.submaps)
        );
    };
  };
}
