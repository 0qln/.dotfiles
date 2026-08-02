{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  todoist-quick-add = pkgs.callPackage ../../todoist/todoist-quick-add.nix {};
  inherit (config.vars) terminal fileexplorer music-player;
  cfg = config.modules.hyprland.input;
  u = config.utils.hyprLua;
  inherit (u) exec bind bindF toLua;
in {
  config = let
    inherit (cfg) mainMod;
  in {
    wayland.windowManager.hyprland = {
      settings = {
        config = {
          # For some reason hardware_cursors draws the cursor like 250px
          # to the left and some other issues...
          # fix source: https://github.com/hyprwm/Hyprland/issues/8852
          cursor.no_hardware_cursors = true;

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
        };

        bind = mkMerge [
          [
            # Application shortcuts
            (bind "${mainMod} + Q" (exec terminal))
            (bind "${mainMod} + C" (exec "hyprpicker | wl-copy"))
            (bind "${mainMod} + DELETE" "hl.dsp.window.close()")
            (bind "${mainMod} + E" (exec fileexplorer))
            (bind "${mainMod} + V" "hl.dsp.window.float()")
            (bind "${mainMod} + P" "hl.dsp.window.pseudo()")
            (bind "${mainMod} + J" ''hl.dsp.layout("togglesplit")'')
            (bind "${mainMod} + O" (exec "obsidian"))
          ]
          (mkIf config.modules.splatmoji.enable [
            # copypaste or type commands don't work; type bc ydotool is goofy and the prior idk why
            (bind "${mainMod} + E" (exec "splatmoji --disable-emoji-db copy"))
          ])
          (mkIf config.modules.browser.firefox.zen.enable [
            (bind "${mainMod} + Z" (exec "zen"))
          ])
          [
            (bind "${mainMod} + B" (exec "${terminal} -e bluetoothctl"))
          ]
          (mkIf config.modules.todoist.quickAdd.enable (let
            execs = {
              # terminal
              "terminal" = "[float; center; size 600 100] ${terminal} --class todoist-popup -e ${lib.getExe todoist-quick-add}";

              # rofi
              # can't use dmenu, because it outputs the selection, so we cannot get the whole task the user entered.
              "rofi" = "rofi -show run -config ${config.modules.todoist.quickAdd.rofi.configFile}";
            };
          in [
            (bind "${mainMod} + T" (exec execs.${config.modules.todoist.quickAdd.impl}))
          ]))
          [
            # hyprland can't handle zen so we using an electron app grahh
            (bind "${mainMod} + M" (exec music-player))

            # app/window search bar
            (bind "${mainMod} + SPACE" (exec ''rofi -show combi -modes "combi,ssh,recursivebrowser" -combi-modes "window,run,drun"''))

            # file searchbar
            (bind "${mainMod} + F" (exec "rofi -show recursivebrowser"))

            # ssh connections search bar
            (bind "${mainMod} + S" (exec "rofi -show ssh"))

            # Focus movement
            (bind "ALT + SHIFT + H" ''hl.dsp.focus({ direction = "l" })'')
            (bind "ALT + SHIFT + L" ''hl.dsp.focus({ direction = "r" })'')
            (bind "ALT + SHIFT + K" ''hl.dsp.focus({ direction = "u" })'')
            (bind "ALT + SHIFT + J" ''hl.dsp.focus({ direction = "d" })'')
            (bind "ALT + SHIFT + N" ''hl.dsp.focus({ window = "floating" })'')
          ]

          # Workspace navigation
          (map (n: bind "ALT + SHIFT + ${toString n}" "hl.dsp.focus({ workspace = ${toString n} })") (range 1 9))
          [(bind "ALT + SHIFT + 0" "hl.dsp.focus({ workspace = 10 })")]

          # Move windows to workspaces
          (map (n: bind "CTRL + ALT + ${toString n}" "hl.dsp.window.move({ workspace = ${toString n} })") (range 1 9))
          [(bind "CTRL + ALT + 0" "hl.dsp.window.move({ workspace = 10 })")]

          [
            (bind "CTRL + ALT + H" ''hl.dsp.window.move({ direction = "l" })'')
            (bind "CTRL + ALT + J" ''hl.dsp.window.move({ direction = "d" })'')
            (bind "CTRL + ALT + K" ''hl.dsp.window.move({ direction = "u" })'')
            (bind "CTRL + ALT + L" ''hl.dsp.window.move({ direction = "r" })'')

            (bind "CTRL + ALT + P" "hl.dsp.window.pseudo()")
            (bind "CTRL + ALT + C" "hl.dsp.window.center()")
            (bind "CTRL + ALT + B" "hl.dsp.window.float()")
            (bind "CTRL + ALT + M" "hl.dsp.window.fullscreen_state({ internal = 0, client = -1 })")
            (bind "CTRL + ALT + N" "hl.dsp.window.fullscreen_state({ internal = 1, client = -1 })")
            (bind "CTRL + ALT + F" "hl.dsp.window.fullscreen_state({ internal = 2, client = -1 })")
            (bind "CTRL + SHIFT + M" "hl.dsp.window.fullscreen_state({ internal = -1, client = 0 })")
            (bind "CTRL + SHIFT + N" "hl.dsp.window.fullscreen_state({ internal = -1, client = 1 })")
            (bind "CTRL + SHIFT + F" "hl.dsp.window.fullscreen_state({ internal = -1, client = 2 })")

            # Special workspace
            (bind "ALT + SHIFT + S" ''hl.dsp.workspace.toggle_special("magic")'')
            (bind "CTRL + ALT + S" ''hl.dsp.window.move({ workspace = "special:magic" })'')

            # Multimedia keys
            (bind "XF86AudioRaiseVolume" (exec "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"))
            (bind "XF86AudioLowerVolume" (exec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))
            (bind "XF86AudioMute" (exec "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
            (bind "XF86AudioMicMute" (exec "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))
            (bind "XF86MonBrightnessUp" (exec "brightnessctl -e4 -n2 set 5%+"))
            (bind "XF86MonBrightnessDown" (exec "brightnessctl -e4 -n2 set 5%-"))
            (bind "XF86AudioNext" (exec "playerctl next"))
            (bind "XF86AudioPause" (exec "playerctl play-pause"))
            (bind "XF86AudioPlay" (exec "playerctl play-pause"))
            (bind "XF86AudioPrev" (exec "playerctl previous"))

            # Mouse bindings
            (bindF "${mainMod} + mouse:272" "hl.dsp.window.drag()" {mouse = true;})
            (bindF "${mainMod} + mouse:273" "hl.dsp.window.resize()" {mouse = true;})
          ]
        ];
      };

      # Submaps (rendered as raw lua `hl.define_submap`).
      extraConfig = let
        # "MODS, KEY" (hyprlang) -> "MODS + KEY" (lua)
        convertKeys = keys: let
          parts = splitString "," keys;
          mods = strings.trim (head parts);
          key = strings.trim (concatStringsSep "," (tail parts));
          modsLua = concatStringsSep " + " (filter (m: m != "") (splitString " " mods));
        in
          if modsLua == ""
          then key
          else "${modsLua} + ${key}";

        flagMap = {
          e = "repeating";
          l = "locked";
          r = "release";
        };
        flagsTable = flags: let
          names = filter (x: x != null) (map (c: flagMap.${c} or null) (stringToCharacters flags));
        in
          if names == []
          then ""
          else ", { ${concatMapStringsSep ", " (n: "${n} = true") names} }";

        mkSubmapBind = bnd:
          if isString bnd
          then bnd
          else let
            keysLua = convertKeys bnd.keys;
            dispCmd = "hyprctl dispatch ${bnd.dispatch}";
            execExpr = "hl.dsp.exec_cmd(${toLua dispCmd})";
          in
            if bnd.reset
            then ''
              hl.bind(${toLua keysLua}, function()
                hl.dispatch(${execExpr})
                hl.dispatch(hl.dsp.submap("reset"))
              end${flagsTable bnd.flags})''
            else "hl.bind(${toLua keysLua}, ${execExpr}${flagsTable bnd.flags})";

        mkSubmap = name: {
          key ? null,
          binds,
        }:
          concatStringsSep "\n" (
            (optional (key != null) ''hl.bind(${toLua "${mainMod} + ${key}"}, hl.dsp.submap(${toLua name}))'')
            ++ [''hl.define_submap(${toLua name}, function()'']
            ++ (map (b: "  " + mkSubmapBind b) binds)
            ++ [
              ''  hl.bind("escape", hl.dsp.submap("reset"))''
              ''  hl.bind("catchall", hl.dsp.submap("reset"))''
              ''end)''
            ]
          );
      in
        concatStringsSep "\n\n" (mapAttrsToList mkSubmap cfg.submaps);
    };
  };
}
