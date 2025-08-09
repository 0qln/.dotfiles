{ ... }: {
  # home.file.".config/kitty/Catppuccin-Mocha.conf" = {
  #   source = ./Catppuccin-Mocha.conf;
  # };
  # .. .and then import it into the kitty.conf with `include ...`

  programs.kitty = {
    enable = true;
    settings = {
      background_opacity = 0.5;
      font_family = "VictorMono Nerd Font";
    };
    themeFile = "Catppuccin-Mocha";
  };
}
