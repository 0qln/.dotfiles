{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.terminal;
in {
  options.modules.terminal.kitty = {
    theme = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "The name of the kitty theme file to use.";
    };
    themeFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "The path of the kitty theme file to use.";
    };
    themeConf = mkOption {
      type = types.nullOr types.lines;
      default = null;
      description = "The kitty theme conf to use.";
    };
  };

  config = mkIf (cfg.emulator == "kitty") {
    programs.kitty = {
      enable = true;
      settings = {
        background_opacity = cfg.backgroundOpacity;

        cursor_trail = 1;
        cursor_trail_decay = "0.1 0.4";

        font_family = mkIf (cfg.font != null) cfg.font;
      };

      keybindings = {
        "ctrl+shift+h" = "previous_tab";
        "ctrl+shift+l" = "next_tab";
        # moves the tab into a new OS window
        "ctrl+f2" = "detach_tab";
        # asks which OS Window to move the tab into
        "ctrl+f4" = "detach_tab ask";
      };

      # themeFile = "Catppuccin-Mocha";
      # themeFile = "Glacier";
      # themeFile = "HachikoRed";
      themeFile = mkIf (cfg.kitty.theme != null) cfg.kitty.theme;

      extraConfig = with config.theme.term;
        mkMerge [
          # module options
          (mkIf (cfg.kitty.themeFile != null) "include ${cfg.kitty.themeFile}")
          (mkIf (cfg.kitty.themeConf != null) "include ${pkgs.writeText "kitty theme conf" cfg.kitty.themeConf}")

          # theme options
          (mkIf (cursor != null) "cursor ${cursor}")
          (mkIf (background != null) "background ${background}")
          (mkIf (foreground != null) "foreground ${foreground}")
          (mkIf (selection_background != null) "selection_background ${selection_background}")
          (mkIf (selection_foreground != null) "selection_foreground ${selection_foreground}")
          (mkIf (color0 != null) "color0 ${color0}")
          (mkIf (color8 != null) "color8 ${color8}")
          (mkIf (color1 != null) "color1 ${color1}")
          (mkIf (color9 != null) "color9 ${color9}")
          (mkIf (color2 != null) "color2 ${color2}")
          (mkIf (color10 != null) "color10 ${color10}")
          (mkIf (color3 != null) "color3 ${color3}")
          (mkIf (color11 != null) "color11 ${color11}")
          (mkIf (color4 != null) "color4 ${color4}")
          (mkIf (color12 != null) "color12 ${color12}")
          (mkIf (color5 != null) "color5 ${color5}")
          (mkIf (color13 != null) "color13 ${color13}")
          (mkIf (color6 != null) "color6 ${color6}")
          (mkIf (color14 != null) "color14 ${color14}")
          (mkIf (color7 != null) "color7 ${color7}")
          (mkIf (color15 != null) "color15 ${color15}")
        ];
    };
  };
}
