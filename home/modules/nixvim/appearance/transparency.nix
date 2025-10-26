{...}: {
  programs.nixvim = {
    plugins = {
      transparent = {
        enable = true;
        settings = {
          auto = true;
          groups = [
          ];
        };
      };
    };
  };
}
