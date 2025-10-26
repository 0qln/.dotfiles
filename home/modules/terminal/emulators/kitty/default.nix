{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.terminal;
in {
  options.modules.terminal.kitty = {
    themeFile = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "The kitty theme file to use.";
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
      themeFile = mkIf (cfg.kitty.themeFile != null) cfg.kitty.themeFile;
    };
  };
}
