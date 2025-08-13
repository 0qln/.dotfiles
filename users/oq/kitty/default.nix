{ ... }:
{
  imports = [
    ../fonts
  ];

  programs.kitty = {
    enable = true;
    settings = {
      background_opacity = 0.5;
      cursor_trail = 1;
      cursor_trail_decay = "0.1 0.4";
      font_family = "VictorMono Nerd Font";
    };
    themeFile = "Catppuccin-Mocha";
  };
}
