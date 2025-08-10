{ ... }:
{
  imports = [
    ../fonts
  ];

  programs.kitty = {
    enable = true;
    settings = {
      background_opacity = 0.5;
      font_family = "VictorMono Nerd Font";
    };
    themeFile = "Catppuccin-Mocha";
  };
}
