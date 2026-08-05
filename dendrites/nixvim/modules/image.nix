{
  pkgs,
  config,
  ...
}: {
  # does not work idk why
  programs.nixvim = {
    extraLuaPackages = ps: [ps.magick];
    extraPackages = with pkgs; [
      # install only what we need
      imagemagick
      curl
      ueberzugpp
    ];
    plugins = {
      image = {
        enable = true;
        settings = {
          backend =
            if
              # TODO: if tui
              false
            then "sixel"
            else if config.vars.terminal == "kitty"
            then "kitty"
            else "ueberzug";
        };
      };
    };
  };
}
