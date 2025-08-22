{ ... }:
{
  imports = [
    ../fonts
  ];

  programs.kitty = {
    enable = true;
    settings = {

      background_opacity = 0.7;

      cursor_trail = 1;
      cursor_trail_decay = "0.1 0.4";

      # font_family = "VictorMono Nerd Font";
      font_family = "Cartograph CF";

    };

    keybindings = {
      "ctrl+shift+h" = "previous_tab";
      "ctrl+shift+l" = "next_tab";
    };

    # themeFile = "Catppuccin-Mocha";
  };
}
